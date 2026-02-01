class WorkflowNode < ApplicationRecord
  belongs_to :workflow
  has_many :outgoing_connections, class_name: 'WorkflowConnection', foreign_key: 'source_node_id', dependent: :destroy
  has_many :incoming_connections, class_name: 'WorkflowConnection', foreign_key: 'target_node_id', dependent: :destroy

  validates :node_type, presence: true
  validates :node_id, presence: true, uniqueness: { scope: :workflow_id }

  serialize :config, type: Hash, coder: JSON

  def to_react_flow_format
    {
      id: node_id,
      type: node_type,
      position: { x: position_x.to_f, y: position_y.to_f },
      data: {
        label: label || service_name || node_type.humanize,
        service_name: service_name,
        config: config || {}
      }
    }
  end
end
