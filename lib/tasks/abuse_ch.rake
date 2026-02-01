namespace :abuse_ch do
  desc "Refresh cached malicious IPs from abuse.ch Feodo Tracker"
  task refresh_cache: :environment do
    puts "Refreshing abuse.ch Feodo Tracker malicious IP cache..."
    
    result = CachedMaliciousIp.refresh_from_abuse_ch
    
    if result[:success]
      puts "✓ Successfully cached #{result[:count]} malicious IPs from abuse.ch"
      puts "  Last updated: #{result[:updated_at]}"
      puts "  Source: Feodo Tracker (Botnet C2 IPs)"
    else
      puts "✗ Failed to refresh cache: #{result[:error]}"
    end
  end
  
  desc "Show abuse.ch cache status"
  task cache_status: :environment do
    count = CachedMaliciousIp.from_abuse_ch.count
    latest = CachedMaliciousIp.from_abuse_ch.maximum(:last_updated_at)
    stale = CachedMaliciousIp.abuse_ch_cache_stale?
    
    puts "abuse.ch Cache Status:"
    puts "  Cached IPs: #{count}"
    puts "  Last updated: #{latest || 'Never'}"
    puts "  Cache stale: #{stale ? 'Yes (>6 hours old)' : 'No (fresh)'}"
    
    if count > 0
      top_5 = CachedMaliciousIp.from_abuse_ch.order(last_updated_at: :desc).limit(5)
      puts "\n  Top 5 Recent Feodo C2 IPs:"
      top_5.each do |ip|
        malware = ip.metadata&.dig('malware') || 'Unknown'
        puts "    #{ip.ip_address} - #{malware} (#{ip.country_code})"
      end
    end
  end
  
  desc "Show combined cache status (all sources)"
  task combined_status: :environment do
    abuse_ch_count = CachedMaliciousIp.from_abuse_ch.count
    abuseipdb_count = CachedMaliciousIp.from_abuseipdb.count
    total = CachedMaliciousIp.count
    
    puts "Combined Threat Intelligence Cache Status:"
    puts "  Total cached IPs: #{total}"
    puts "  abuse.ch (Feodo): #{abuse_ch_count}"
    puts "  AbuseIPDB: #{abuseipdb_count}"
    puts ""
    
    top_10 = CachedMaliciousIp.top_malicious_combined(limit: 10)
    if top_10.any?
      puts "  Top 10 Malicious IPs (Combined):"
      top_10.each_with_index do |ip, idx|
        malware = ip.metadata&.dig('malware') || 'Malicious'
        puts "    #{idx + 1}. #{ip.ip_address} - #{malware} [#{ip.source}]"
      end
    end
  end
end
