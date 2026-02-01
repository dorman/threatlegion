# AbuseIPDB Integration Guide

## Overview

ThreatLegion now integrates with AbuseIPDB to provide IP reputation checking and threat intelligence enrichment.

## Features

### 1. IP Reputation Check
- Check any IP address against the AbuseIPDB database
- View abuse confidence score, ISP information, country, and usage type
- See detailed abuse reports with categories
- Automatically save results as indicators

### 2. Blacklist Import
- Fetch the latest AbuseIPDB blacklist
- Filter by confidence score (default: 90%)
- Import malicious IPs directly into your indicators database
- Bulk import up to 10,000 IPs

### 3. IP Reporting
- Report malicious IPs to AbuseIPDB
- Select from 20+ abuse categories
- Add detailed comments about the abuse

## Configuration

Your API key has been configured in `.env`:
```
ABUSEIPDB_API_KEY=fa1467865a68ad1f31b58827a99c8d1cdd57f804aa60f06c83e561d0eddbc49354d8111f9581e1ed
```

**Security Note:** The `.env` file is gitignored and will not be committed to version control.

## Usage

### Web Interface

#### Check IP Reputation
1. Navigate to **AbuseIPDB** in the main menu
2. Enter an IP address
3. Click "Check IP"
4. View detailed reputation information
5. Optionally save as an indicator

**Direct URL:** `/abuseipdb/check`

#### View Blacklist
1. Navigate to **Indicators** → **View Blacklist**
2. Set filters (limit, confidence minimum)
3. Click "Fetch Blacklist"
4. Review the list of malicious IPs
5. Click "Import to Indicators" to bulk import

**Direct URL:** `/abuseipdb/blacklist`

#### Quick Check from Indicators
- When viewing an IP indicator, click the **"Check AbuseIPDB"** button
- Instantly see reputation data for that IP

### API Usage

The AbuseIPDB service can be used programmatically:

```ruby
# Initialize service
service = AbuseIpdbService.new

# Check an IP
result = service.check_ip('8.8.8.8')
if result[:success]
  puts "Abuse Score: #{result[:abuse_confidence_score]}%"
  puts "Country: #{result[:country_name]}"
  puts "ISP: #{result[:isp]}"
end

# Get blacklist
blacklist = service.blacklist(limit: 100, confidence_minimum: 90)
blacklist[:ips].each do |ip|
  puts "#{ip[:ip_address]} - Score: #{ip[:abuse_confidence_score]}%"
end

# Report an IP
result = service.report_ip(
  '192.168.1.100',
  categories: [14, 15], # Port Scan, Hacking
  comment: 'Attempted SSH brute force'
)
```

## AbuseIPDB Categories

The service supports all AbuseIPDB categories:

| ID | Category |
|----|----------|
| 3 | Fraud Orders |
| 4 | DDoS Attack |
| 5 | FTP Brute-Force |
| 6 | Ping of Death |
| 7 | Phishing |
| 8 | Fraud VoIP |
| 9 | Open Proxy |
| 10 | Web Spam |
| 11 | Email Spam |
| 12 | Blog Spam |
| 13 | VPN IP |
| 14 | Port Scan |
| 15 | Hacking |
| 16 | SQL Injection |
| 17 | Spoofing |
| 18 | Brute-Force |
| 19 | Bad Web Bot |
| 20 | Exploited Host |
| 21 | Web App Attack |
| 22 | SSH |
| 23 | IoT Targeted |

## Rate Limits

AbuseIPDB has the following rate limits based on your plan:

- **Free Plan:** 1,000 requests/day
- **Basic Plan:** 3,000 requests/day
- **Premium Plan:** 10,000+ requests/day

The integration includes error handling for rate limit exceeded responses.

## Automated Workflows

### Daily Blacklist Import (Recommended)

Set up a cron job or Sidekiq scheduled job to automatically import the blacklist:

```ruby
# In config/schedule.rb (using whenever gem)
every 1.day, at: '2:00 am' do
  rake "abuseipdb:import_blacklist"
end
```

Create the rake task:

```ruby
# lib/tasks/abuseipdb.rake
namespace :abuseipdb do
  desc "Import AbuseIPDB blacklist"
  task import_blacklist: :environment do
    service = AbuseIpdbService.new
    result = service.blacklist(limit: 1000, confidence_minimum: 90)
    
    if result[:success]
      result[:ips].each do |ip_data|
        Indicator.find_or_create_by(
          indicator_type: 'ip',
          value: ip_data[:ip_address]
        ) do |indicator|
          indicator.confidence = ip_data[:abuse_confidence_score]
          indicator.source = 'AbuseIPDB'
          indicator.tags = ['abuseipdb', 'blacklist']
          indicator.first_seen = Time.current
          indicator.last_seen = Time.current
        end
      end
      puts "✓ Imported #{result[:ips].size} IPs from AbuseIPDB"
    else
      puts "✗ Error: #{result[:error]}"
    end
  end
end
```

### Auto-Check New IP Indicators

Add a callback to automatically check new IP indicators:

```ruby
# In app/models/indicator.rb
after_create :check_abuseipdb, if: -> { indicator_type == 'ip' }

private

def check_abuseipdb
  CheckAbuseipdbJob.perform_later(id)
end
```

## Troubleshooting

### API Key Issues
- Verify your API key is correctly set in `.env`
- Restart the Rails server after changing `.env`
- Check API key validity at https://www.abuseipdb.com/account/api

### Rate Limit Errors
- Monitor your daily request count
- Implement caching for frequently checked IPs
- Upgrade your AbuseIPDB plan if needed

### Connection Errors
- Check your internet connection
- Verify AbuseIPDB API is accessible
- Review firewall settings

## Best Practices

1. **Cache Results:** Store AbuseIPDB results to avoid redundant API calls
2. **Batch Processing:** Use bulk check for multiple IPs when possible
3. **Regular Updates:** Import the blacklist daily to stay current
4. **Report Back:** Report malicious IPs you discover to help the community
5. **Monitor Usage:** Track your API usage to avoid hitting rate limits

## Resources

- [AbuseIPDB Website](https://www.abuseipdb.com/)
- [AbuseIPDB API Documentation](https://docs.abuseipdb.com/)
- [AbuseIPDB Categories](https://www.abuseipdb.com/categories)

## Support

For issues with the integration:
1. Check the Rails logs: `tail -f log/development.log`
2. Verify API key configuration
3. Test API connectivity manually
4. Review error messages in the UI

For AbuseIPDB API issues:
- Contact AbuseIPDB support: support@abuseipdb.com
- Check API status: https://status.abuseipdb.com/
