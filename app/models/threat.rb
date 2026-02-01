class Threat < ApplicationRecord
  belongs_to :user
  has_many :indicators, dependent: :destroy
  has_many :mitre_attacks, dependent: :destroy
  has_many :vulnerabilities, dependent: :destroy

  validates :name, presence: true
  validates :threat_type, inclusion: { in: %w[malware apt phishing ransomware botnet exploit ddos], allow_nil: true }
  validates :severity, inclusion: { in: %w[critical high medium low info], allow_nil: true }
  validates :status, inclusion: { in: %w[active investigating mitigated closed], allow_nil: true }
  validates :confidence_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :active, -> { where(status: "active") }
  scope :critical, -> { where(severity: "critical") }
  scope :high_severity, -> { where(severity: ["critical", "high"]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(threat_type: type) }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "threat_type", "severity", "status", "description", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["indicators", "mitre_attacks", "vulnerabilities", "user"]
  end
end
