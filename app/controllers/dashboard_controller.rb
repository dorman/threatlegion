class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_threats = Threat.count
    @active_threats = Threat.active.count
    @critical_threats = Threat.critical.count
    @total_indicators = Indicator.count
    @total_vulnerabilities = Vulnerability.count

    @recent_threats = Threat.recent.limit(10)
    @threats_by_type = Threat.group(:threat_type).count
    @threats_by_severity = Threat.group(:severity).count
    @indicators_by_type = Indicator.group(:indicator_type).count

    @threats_over_time = Threat.group_by_day(:created_at, last: 30).count
    @indicators_over_time = Indicator.group_by_day(:created_at, last: 30).count

    # Fetch abuse.ch threat intelligence data (must be before score calculation)
    fetch_abuse_ch_data
    
    # Calculate overall security severity score
    calculate_security_score
  end

  private

  def calculate_security_score
    # Enhanced DEFCON-style threat severity algorithm (0-100)
    # Incorporates internal threats + external abuse.ch intelligence
    # Higher score = more severe threat landscape
    
    # === INTERNAL THREAT WEIGHTS ===
    critical_threat_weight = 8
    high_threat_weight = 4
    medium_threat_weight = 2
    active_threat_weight = 3
    indicator_weight = 1
    vulnerability_weight = 6
    
    # === EXTERNAL THREAT WEIGHTS (abuse.ch) ===
    feodo_c2_weight = 5        # Active botnet C2 servers
    online_url_weight = 7      # Currently online malicious URLs
    malware_payload_weight = 3 # Recent malware samples
    
    # Count internal threats
    critical_count = Threat.where(severity: 'critical').count
    high_count = Threat.where(severity: 'high').count
    medium_count = Threat.where(severity: 'medium').count
    high_confidence_indicators = Indicator.where('confidence >= ?', 75).count
    critical_vulns = Vulnerability.where(severity_level: 'critical').count rescue 0
    
    # Count external threats (abuse.ch)
    feodo_online_count = CachedMaliciousIp.from_abuse_ch
      .where("metadata->>'status' = ?", 'online').count
    urlhaus_online_count = @urlhaus_online || 0
    recent_payloads_count = @payloads_count || 0
    
    # Calculate component scores
    internal_score = (critical_count * critical_threat_weight) +
                     (high_count * high_threat_weight) +
                     (medium_count * medium_threat_weight) +
                     (@active_threats * active_threat_weight) +
                     (high_confidence_indicators * indicator_weight) +
                     (critical_vulns * vulnerability_weight)
    
    external_score = (feodo_online_count * feodo_c2_weight) +
                     (urlhaus_online_count * online_url_weight) +
                     ([recent_payloads_count, 20].min * malware_payload_weight)
    
    # Normalize to 0-100 scale
    # Max expected: 10 critical, 20 high, 30 medium, 15 active, 50 indicators, 5 vulns
    # + 10 feodo online, 15 urls online, 20 payloads
    max_internal = (10 * critical_threat_weight) + (20 * high_threat_weight) + 
                   (30 * medium_threat_weight) + (15 * active_threat_weight) + 
                   (50 * indicator_weight) + (5 * vulnerability_weight)
    max_external = (10 * feodo_c2_weight) + (15 * online_url_weight) + (20 * malware_payload_weight)
    
    # Weight internal threats at 60%, external at 40%
    normalized_internal = (internal_score.to_f / max_internal * 60).round
    normalized_external = (external_score.to_f / max_external * 40).round
    
    @security_score = [normalized_internal + normalized_external, 100].min
    @threat_level = ThreatScore.calculate_threat_level(@security_score)
    @threat_level_config = ThreatScore::THREAT_LEVELS[@threat_level]
    
    # Store component scores for display
    @score_components = {
      critical_threats: critical_count,
      high_threats: high_count,
      medium_threats: medium_count,
      active_threats: @active_threats,
      high_confidence_indicators: high_confidence_indicators,
      critical_vulnerabilities: critical_vulns,
      feodo_online: feodo_online_count,
      urlhaus_online: urlhaus_online_count,
      recent_payloads: [recent_payloads_count, 20].min,
      internal_score: normalized_internal,
      external_score: normalized_external
    }
    
    # Record score for historical tracking (once per hour)
    last_score = ThreatScore.recent.first
    if last_score.nil? || last_score.recorded_at < 1.hour.ago
      ThreatScore.record_score(@security_score, @score_components)
    end
  end

  def fetch_abuse_ch_data
    service = AbuseChService.new
    
    # Get Feodo Tracker C2 IPs (top 5)
    @feodo_ips_count = CachedMaliciousIp.from_abuse_ch.count
    @feodo_last_updated = CachedMaliciousIp.from_abuse_ch.maximum(:last_updated_at)
    @top_feodo_ips = CachedMaliciousIp.from_abuse_ch.order(last_updated_at: :desc).limit(5)
    
    # Get recent malicious URLs (top 5, cached)
    cached_urls_data = Rails.cache.fetch('abuse_ch_recent_urls_data', expires_in: 1.hour) do
      result = service.get_recent_urls(limit: 100)
      if result[:success]
        {
          urls: result[:urls].first(5),
          count: result[:count],
          online: result[:urls].count { |u| u[:url_status] == 'online' }
        }
      else
        { urls: [], count: 0, online: 0 }
      end
    end
    
    @top_urlhaus_urls = cached_urls_data[:urls]
    @urlhaus_count = cached_urls_data[:count]
    @urlhaus_online = cached_urls_data[:online]
    
    # Get recent malware payloads (top 5, cached)
    cached_payloads = Rails.cache.fetch('abuse_ch_recent_payloads_data', expires_in: 1.hour) do
      result = service.get_recent_payloads(limit: 100)
      if result[:success]
        { payloads: result[:payloads].first(5), count: result[:count] }
      else
        { payloads: [], count: 0 }
      end
    end
    
    @top_payloads = cached_payloads[:payloads]
    @payloads_count = cached_payloads[:count]
  rescue StandardError => e
    @feodo_ips_count = 0
    @urlhaus_count = 0
    @urlhaus_online = 0
    @top_feodo_ips = []
    @top_urlhaus_urls = []
    @top_payloads = []
    @payloads_count = 0
  end

  def analytics
    @threats_by_month = Threat.group_by_month(:created_at, last: 12).count
    @high_confidence_indicators = Indicator.high_confidence.count
    @vulnerability_severity = Vulnerability.all.group_by(&:severity_level).transform_values(&:count)
  end
end
