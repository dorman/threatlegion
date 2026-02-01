class MitreAttack < ApplicationRecord
  belongs_to :threat

  validates :tactic, presence: true
  validates :technique, presence: true
  validates :technique_id, presence: true, format: { with: /\AT\d{4}(\.\d{3})?\z/, message: "must be valid MITRE ATT&CK ID (e.g., T1566 or T1566.001)" }
end
