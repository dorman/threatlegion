class ThreatFeed < ApplicationRecord
  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :feed_type, inclusion: { in: %w[json csv xml stix], allow_nil: true }

  scope :enabled, -> { where(enabled: true) }
  scope :needs_refresh, -> { where("last_fetched IS NULL OR last_fetched < ?", Time.current - 1.hour) }

  def needs_refresh?
    return false unless enabled
    last_fetched.nil? || last_fetched < 1.hour.ago
  end

  def fetch_data
    return unless enabled

    response = HTTParty.get(url, timeout: 30)
    update(last_fetched: Time.current)
    
    case feed_type
    when "json"
      JSON.parse(response.body)
    when "csv"
      CSV.parse(response.body, headers: true)
    else
      response.body
    end
  rescue StandardError => e
    Rails.logger.error("Failed to fetch threat feed #{name}: #{e.message}")
    nil
  end
end
