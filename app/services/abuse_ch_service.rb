class AbuseChService
  FEODO_TRACKER_URL = 'https://feodotracker.abuse.ch/downloads/ipblocklist.json'
  URLHAUS_CSV_URL = 'https://urlhaus.abuse.ch/downloads/csv_recent/'
  URLHAUS_PAYLOADS_URL = 'https://urlhaus-api.abuse.ch/v1/payloads/recent'
  
  def initialize(api_key = nil)
    @api_key = api_key || ENV['ABUSECH_API_KEY']
  end

  # Get Feodo Tracker botnet C2 IPs
  def get_feodo_ips
    begin
      response = HTTParty.get(
        FEODO_TRACKER_URL,
        timeout: 30,
        headers: {
          'Accept' => 'application/json',
          'User-Agent' => 'ThreatLegion/1.0'
        }
      )

      if response.success?
        data = JSON.parse(response.body)
        
        ips = data.map do |entry|
          {
            ip_address: entry['ip_address'],
            port: entry['port'],
            status: entry['status'],
            hostname: entry['hostname'],
            as_number: entry['as_number'],
            as_name: entry['as_name'],
            country: entry['country'],
            first_seen: entry['first_seen'],
            last_seen: entry['last_seen'],
            malware: entry['malware']
          }
        end
        
        { success: true, ips: ips, count: ips.count }
      else
        { success: false, error: "HTTP #{response.code}: #{response.message}" }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end
  end

  # Get recent malicious URLs from URLhaus (CSV feed - no auth required)
  def get_recent_urls(limit: 100)
    begin
      response = HTTParty.get(
        URLHAUS_CSV_URL,
        timeout: 30,
        headers: {
          'User-Agent' => 'ThreatLegion/1.0'
        }
      )

      if response.success?
        # Parse CSV data (skip comment lines starting with #)
        lines = response.body.split("\n").reject { |line| line.start_with?('#') || line.strip.empty? }
        
        urls = []
        lines.first(limit).each do |line|
          fields = line.split(',')
          next if fields.length < 8
          
          begin
            host = URI.parse(fields[2]&.gsub('"', '')).host
          rescue
            host = 'Unknown'
          end
          
          urls << {
            id: fields[0],
            date_added: fields[1],
            url: fields[2]&.gsub('"', ''),
            url_status: fields[3],
            threat: fields[4],
            tags: fields[5]&.split('|') || [],
            urlhaus_link: fields[6],
            reporter: fields[7],
            host: host
          }
        end
        
        { success: true, urls: urls, count: urls.count }
      else
        { success: false, error: "HTTP #{response.code}: #{response.message}" }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end
  end

  # Get recent malware payloads
  # Note: URLhaus payloads endpoint requires API authentication
  # This endpoint may require registration and API key from abuse.ch
  def get_recent_payloads(limit: 100)
    begin
      # Check if API key is available
      unless @api_key.present?
        return { 
          success: false, 
          error: "API key required. URLhaus payloads endpoint requires authentication. Please set ABUSECH_API_KEY environment variable." 
        }
      end
      
      # Build request with API key
      headers = {
        'Accept' => 'application/json',
        'User-Agent' => 'ThreatLegion/1.0',
        'Content-Type' => 'application/json'
      }
      
      # URLhaus API typically requires API key in the request body
      body = {
        limit: limit
      }
      
      # Some URLhaus endpoints accept API key in Authorization header
      # Try both methods
      response = HTTParty.post(
        URLHAUS_PAYLOADS_URL,
        body: body.to_json,
        timeout: 30,
        headers: headers.merge('Authorization' => "Bearer #{@api_key}")
      )

      # If that fails, try with API key in body
      if !response.success? && response.code == 401
        body[:api_key] = @api_key
        response = HTTParty.post(
          URLHAUS_PAYLOADS_URL,
          body: body.to_json,
          timeout: 30,
          headers: headers
        )
      end

      if response.success?
        data = JSON.parse(response.body)
        
        if data['query_status'] == 'ok' && data['payloads']
          payloads = data['payloads'].map do |entry|
            {
              sha256_hash: entry['sha256_hash'],
              md5_hash: entry['md5_hash'],
              file_type: entry['file_type'],
              file_size: entry['file_size'],
              signature: entry['signature'],
              firstseen: entry['firstseen'],
              urlhaus_download: entry['urlhaus_download'],
              virustotal: entry['virustotal']
            }
          end
          
          { success: true, payloads: payloads.first(limit), count: payloads.count }
        elsif data['query_status']
          { success: false, error: data['query_status'] }
        else
          { success: false, error: 'Invalid response format from URLhaus API' }
        end
      else
        error_msg = "HTTP #{response.code}: #{response.message}"
        # Try to parse error message from response
        begin
          error_data = JSON.parse(response.body)
          error_msg = error_data['error'] || error_data['message'] || error_data['query_status'] || error_msg
        rescue
          # Use default error message
        end
        
        { success: false, error: error_msg }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end
  end

  # Helper method to get threat level color
  def self.threat_color(threat_type)
    case threat_type&.downcase
    when 'malware_download'
      'red'
    when 'botnet_cc'
      'orange'
    when 'phishing'
      'yellow'
    else
      'gray'
    end
  end

  # Helper method to get status color
  def self.status_color(status)
    case status&.downcase
    when 'online'
      'red'
    when 'offline'
      'gray'
    else
      'yellow'
    end
  end
end
