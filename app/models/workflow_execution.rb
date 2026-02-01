class WorkflowExecution < ApplicationRecord
  belongs_to :workflow
  belongs_to :user

  validates :status, inclusion: { in: %w[pending running completed failed] }

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }

  serialize :result_data, type: Hash, coder: JSON

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def success?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end
end
