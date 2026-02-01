class ThreatScore < ApplicationRecord
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :threat_level, presence: true
  validates :recorded_at, presence: true
  
  # Scopes
  scope :recent, -> { order(recorded_at: :desc) }
  scope :last_30_days, -> { where('recorded_at >= ?', 30.days.ago) }
  scope :last_7_days, -> { where('recorded_at >= ?', 7.days.ago) }
  
  # DEFCON-style threat levels
  THREAT_LEVELS = {
    'DEFCON 5' => { range: 0..20, color: 'green', description: 'Minimal Threat - Normal peacetime readiness' },
    'DEFCON 4' => { range: 21..40, color: 'blue', description: 'Low Threat - Increased intelligence watch' },
    'DEFCON 3' => { range: 41..60, color: 'yellow', description: 'Moderate Threat - Increase in force readiness' },
    'DEFCON 2' => { range: 61..80, color: 'orange', description: 'High Threat - Further increase in force readiness' },
    'DEFCON 1' => { range: 81..100, color: 'red', description: 'Severe Threat - Maximum readiness' }
  }.freeze
  
  # Calculate threat level from score
  def self.calculate_threat_level(score)
    THREAT_LEVELS.each do |level, config|
      return level if config[:range].include?(score)
    end
    'DEFCON 5'
  end
  
  # Get threat level config
  def threat_level_config
    THREAT_LEVELS[threat_level] || THREAT_LEVELS['DEFCON 5']
  end
  
  # Record a new score
  def self.record_score(score, components = {})
    threat_level = calculate_threat_level(score)
    create!(
      score: score,
      threat_level: threat_level,
      components: components,
      recorded_at: Time.current
    )
  end
end
