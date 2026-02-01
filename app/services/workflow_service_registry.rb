class WorkflowServiceRegistry
  SERVICES = {
    'abuse_ch' => {
      name: 'abuse.ch',
      description: 'Threat intelligence from abuse.ch (Feodo Tracker, URLhaus)',
      category: 'threat_intelligence',
      methods: {
        'get_feodo_ips' => {
          name: 'Get Feodo C2 IPs',
          description: 'Fetch botnet C2 server IPs from Feodo Tracker',
          inputs: {},
          outputs: { data: 'array' }
        },
        'get_recent_urls' => {
          name: 'Get Recent URLs',
          description: 'Fetch recent malicious URLs from URLhaus',
          inputs: { limit: { type: 'integer', default: 100 } },
          outputs: { data: 'array' }
        },
        'get_recent_payloads' => {
          name: 'Get Recent Payloads',
          description: 'Fetch recent malware payloads from URLhaus',
          inputs: { limit: { type: 'integer', default: 100 } },
          outputs: { data: 'array' }
        }
      }
    },
    'abuseipdb' => {
      name: 'AbuseIPDB',
      description: 'IP reputation and abuse checking',
      category: 'threat_intelligence',
      methods: {
        'check_ip' => {
          name: 'Check IP Reputation',
          description: 'Check IP address reputation',
          inputs: { ip: { type: 'string', required: true } },
          outputs: { data: 'object' }
        },
        'get_blacklist' => {
          name: 'Get Blacklist',
          description: 'Fetch AbuseIPDB blacklist',
          inputs: { 
            limit: { type: 'integer', default: 1000 },
            confidence_minimum: { type: 'integer', default: 90 }
          },
          outputs: { data: 'array' }
        }
      }
    },
    'filter' => {
      name: 'Filter',
      description: 'Filter data based on conditions',
      category: 'transform',
      methods: {
        'filter_by_field' => {
          name: 'Filter by Field',
          description: 'Filter array data by field value',
          inputs: {
            field: { type: 'string', required: true },
            operator: { type: 'string', default: 'equals' }, # equals, contains, greater_than, less_than
            value: { type: 'string', required: true }
          },
          outputs: { data: 'array' }
        }
      }
    },
    'transform' => {
      name: 'Transform',
      description: 'Transform data structure',
      category: 'transform',
      methods: {
        'map_fields' => {
          name: 'Map Fields',
          description: 'Map/rename fields in data',
          inputs: {
            field_mapping: { type: 'object', required: true }
          },
          outputs: { data: 'array' }
        }
      }
    },
    'output' => {
      name: 'Output',
      description: 'Display or export data',
      category: 'output',
      methods: {
        'display_list' => {
          name: 'Display as List',
          description: 'Display data as a list',
          inputs: {},
          outputs: { data: 'array' }
        },
        'export_csv' => {
          name: 'Export to CSV',
          description: 'Export data to CSV format',
          inputs: {},
          outputs: { data: 'string' }
        }
      }
    }
  }.freeze

  def self.all_services
    SERVICES.keys
  end

  def self.service_info(service_name)
    SERVICES[service_name]
  end

  def self.service_methods(service_name)
    SERVICES.dig(service_name, :methods) || {}
  end

  def self.execute_service(service_name, method_name, inputs = {})
    case service_name
    when 'abuse_ch'
      execute_abuse_ch(method_name, inputs)
    when 'abuseipdb'
      execute_abuseipdb(method_name, inputs)
    when 'filter'
      execute_filter(method_name, inputs)
    when 'transform'
      execute_transform(method_name, inputs)
    when 'output'
      execute_output(method_name, inputs)
    else
      { success: false, error: "Unknown service: #{service_name}" }
    end
  end

  private

  def self.execute_abuse_ch(method_name, inputs)
    service = AbuseChService.new
    case method_name
    when 'get_feodo_ips'
      service.get_feodo_ips
    when 'get_recent_urls'
      service.get_recent_urls(limit: inputs[:limit] || 100)
    when 'get_recent_payloads'
      service.get_recent_payloads(limit: inputs[:limit] || 100)
    else
      { success: false, error: "Unknown method: #{method_name}" }
    end
  end

  def self.execute_abuseipdb(method_name, inputs)
    # Placeholder - would need AbuseIpdbService
    { success: false, error: "AbuseIPDB service not yet implemented" }
  end

  def self.execute_filter(method_name, inputs)
    case method_name
    when 'filter_by_field'
      data = inputs[:data] || []
      field = inputs[:field]
      operator = inputs[:operator] || 'equals'
      value = inputs[:value]

      filtered = data.select do |item|
        item_value = item.is_a?(Hash) ? item[field.to_sym] || item[field.to_s] : nil
        case operator
        when 'equals'
          item_value.to_s == value.to_s
        when 'contains'
          item_value.to_s.include?(value.to_s)
        when 'greater_than'
          item_value.to_f > value.to_f
        when 'less_than'
          item_value.to_f < value.to_f
        else
          false
        end
      end

      { success: true, data: filtered, count: filtered.count }
    else
      { success: false, error: "Unknown method: #{method_name}" }
    end
  end

  def self.execute_transform(method_name, inputs)
    case method_name
    when 'map_fields'
      data = inputs[:data] || []
      mapping = inputs[:field_mapping] || {}

      transformed = data.map do |item|
        new_item = {}
        item.each do |key, val|
          new_key = mapping[key.to_s] || mapping[key.to_sym] || key
          new_item[new_key] = val
        end
        new_item
      end

      { success: true, data: transformed, count: transformed.count }
    else
      { success: false, error: "Unknown method: #{method_name}" }
    end
  end

  def self.execute_output(method_name, inputs)
    data = inputs[:data] || []
    case method_name
    when 'display_list'
      { success: true, data: data, count: data.count }
    when 'export_csv'
      require 'csv'
      csv_string = CSV.generate do |csv|
        if data.first.is_a?(Hash)
          csv << data.first.keys
          data.each { |row| csv << row.values }
        else
          data.each { |row| csv << [row] }
        end
      end
      { success: true, data: csv_string, count: data.count }
    else
      { success: false, error: "Unknown method: #{method_name}" }
    end
  end
end
