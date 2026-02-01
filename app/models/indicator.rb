class Indicator < ApplicationRecord
  belongs_to :threat, optional: true

  validates :indicator_type, presence: true, inclusion: { in: %w[ip domain url hash email file_path registry_key] }
  validates :value, presence: true
  validates :confidence, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :by_type, ->(type) { where(indicator_type: type) }
  scope :high_confidence, -> { where("confidence >= ?", 70) }
  scope :recent, -> { order(last_seen: :desc) }

  serialize :tags, type: Array, coder: JSON

  def self.ransackable_attributes(auth_object = nil)
    ["indicator_type", "value", "confidence", "source", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["threat"]
  end
end
