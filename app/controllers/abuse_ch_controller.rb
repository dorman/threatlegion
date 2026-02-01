class AbuseChController < ApplicationController
  before_action :authenticate_user!

  def index
    # Main abuse.ch dashboard
    @feodo_count = CachedMaliciousIp.from_abuse_ch.count
    @feodo_latest = CachedMaliciousIp.from_abuse_ch.maximum(:last_updated_at)
  end

  def recent_urls
    # Get recent malicious URLs from URLhaus
    service = AbuseChService.new
    
    # Cache for 1 hour to avoid excessive requests
    cached_data = Rails.cache.fetch('abuse_ch_recent_urls', expires_in: 1.hour) do
      service.get_recent_urls(limit: 100)
    end
    
    if cached_data[:success]
      @urls = cached_data[:urls]
      @total_count = cached_data[:count]
    else
      @error = cached_data[:error]
      @urls = []
    end
  rescue StandardError => e
    @error = e.message
    @urls = []
  end

  def recent_payloads
    # Get recent malware payloads from URLhaus
    service = AbuseChService.new
    
    # Cache for 1 hour
    cached_data = Rails.cache.fetch('abuse_ch_recent_payloads', expires_in: 1.hour) do
      service.get_recent_payloads(limit: 100)
    end
    
    if cached_data[:success]
      @payloads = cached_data[:payloads]
      @total_count = cached_data[:count]
    else
      @error = cached_data[:error]
      @payloads = []
    end
  rescue StandardError => e
    @error = e.message
    @payloads = []
  end

  def feodo_tracker
    # Show Feodo Tracker C2 IPs
    @ips = CachedMaliciousIp.from_abuse_ch.order(last_updated_at: :desc).limit(100)
    @last_updated = CachedMaliciousIp.from_abuse_ch.maximum(:last_updated_at)
  end

  def refresh_feodo
    # Manually refresh Feodo Tracker data
    result = CachedMaliciousIp.refresh_from_abuse_ch
    
    if result[:success]
      flash[:notice] = "Successfully refreshed #{result[:count]} Feodo C2 IPs from abuse.ch"
    else
      flash[:alert] = "Failed to refresh: #{result[:error]}"
    end
    
    redirect_to abuse_ch_feodo_tracker_path
  end
end
