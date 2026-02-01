class CachedMaliciousIp < ApplicationRecord
  validates :ip_address, presence: true, uniqueness: true
  validates :source, presence: true
  
  scope :recent, -> { order(last_updated_at: :desc) }
  scope :high_confidence, -> { where('abuse_confidence_score >= ?', 90) }
  scope :from_abuseipdb, -> { where(source: 'AbuseIPDB') }
  scope :from_abuse_ch, -> { where(source: 'abuse.ch') }
  
  # Check if cache is stale (older than 12 hours)
  def self.cache_stale?
    latest = from_abuseipdb.maximum(:last_updated_at)
    latest.nil? || latest < 12.hours.ago
  end
  
  # Get top malicious IPs
  def self.top_malicious(limit: 20)
    from_abuseipdb.high_confidence.recent.limit(limit)
  end
  
  # Update cache from AbuseIPDB
  def self.refresh_from_abuseipdb
    service = AbuseIpdbService.new
    result = service.blacklist(limit: 50, confidence_minimum: 90)
    
    if result[:success]
      result[:ips].each do |ip_data|
        find_or_initialize_by(ip_address: ip_data[:ip_address], source: 'AbuseIPDB').tap do |record|
          record.country_code = ip_data[:country_code]
          record.abuse_confidence_score = ip_data[:abuse_confidence_score]
          record.last_reported_at = ip_data[:last_reported_at]
          record.last_updated_at = Time.current
          record.metadata = ip_data
          record.save
        end
      end
      
      # Clean up old entries (keep only last 100)
      old_ids = from_abuseipdb.order(last_updated_at: :desc).offset(100).pluck(:id)
      where(id: old_ids).delete_all if old_ids.any?
      
      { success: true, count: result[:ips].count, updated_at: Time.current }
    else
      { success: false, error: result[:error] }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end
  
  # Update cache from abuse.ch Feodo Tracker
  def self.refresh_from_abuse_ch
    service = AbuseChService.new
    result = service.get_feodo_ips
    
    if result[:success]
      result[:ips].each do |ip_data|
        find_or_initialize_by(ip_address: ip_data[:ip_address], source: 'abuse.ch').tap do |record|
          record.country_code = ip_data[:country]
          record.abuse_confidence_score = 100 # Feodo IPs are confirmed C2 servers
          # Use last_seen if available, otherwise use first_seen
          record.last_reported_at = ip_data[:last_seen] || ip_data[:first_seen] || Time.current
          record.last_updated_at = Time.current
          record.metadata = ip_data
          record.save
        end
      end
      
      # Clean up old abuse.ch entries (keep only last 200)
      old_ids = from_abuse_ch.order(last_updated_at: :desc).offset(200).pluck(:id)
      where(id: old_ids).delete_all if old_ids.any?
      
      { success: true, count: result[:ips].count, updated_at: Time.current }
    else
      { success: false, error: result[:error] }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end
  
  # Check if abuse.ch cache is stale (older than 6 hours)
  def self.abuse_ch_cache_stale?
    latest = from_abuse_ch.maximum(:last_updated_at)
    latest.nil? || latest < 6.hours.ago
  end
  
  # Get combined top malicious IPs from all sources
  def self.top_malicious_combined(limit: 20)
    where(source: ['AbuseIPDB', 'abuse.ch'])
      .where('abuse_confidence_score >= ?', 90)
      .order(abuse_confidence_score: :desc, last_updated_at: :desc)
      .limit(limit)
  end
end
