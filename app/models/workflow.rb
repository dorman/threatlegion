class Workflow < ApplicationRecord
  belongs_to :user
  has_many :workflow_nodes, dependent: :destroy
  has_many :workflow_connections, dependent: :destroy
  has_many :workflow_executions, dependent: :destroy

  validates :name, presence: true
  validates :status, inclusion: { in: %w[draft active archived] }

  serialize :config, coder: JSON

  scope :active, -> { where(status: 'active') }
  scope :draft, -> { where(status: 'draft') }

  def execute(user)
    WorkflowExecutionService.new(self, user).execute
  end

  def to_react_flow_format
    {
      nodes: workflow_nodes.map(&:to_react_flow_format),
      edges: workflow_connections.map(&:to_react_flow_format)
    }
  end

  def from_react_flow_format(nodes_data, edges_data)
    transaction do
      workflow_nodes.destroy_all
      workflow_connections.destroy_all

      nodes_data.each do |node_data|
        # Convert config to hash if it's ActionController::Parameters
        config = node_data['data']['config'] || {}
        config = config.to_h if config.respond_to?(:to_h)
        config = {} unless config.is_a?(Hash)
        
        workflow_nodes.create!(
          node_id: node_data['id'],
          node_type: node_data['type'],
          service_name: node_data['data']['service_name'],
          label: node_data['data']['label'],
          position_x: node_data['position']['x'],
          position_y: node_data['position']['y'],
          config: config
        )
      end

      edges_data.each do |edge_data|
        source_node = workflow_nodes.find_by(node_id: edge_data['source'])
        target_node = workflow_nodes.find_by(node_id: edge_data['target'])

        next unless source_node && target_node

        workflow_connections.create!(
          source_node: source_node,
          target_node: target_node,
          source_output: edge_data['sourceHandle'],
          target_input: edge_data['targetHandle']
        )
      end
    end
  end
end
