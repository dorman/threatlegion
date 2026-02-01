class WorkflowConnection < ApplicationRecord
  belongs_to :workflow
  belongs_to :source_node, class_name: 'WorkflowNode'
  belongs_to :target_node, class_name: 'WorkflowNode'

  def to_react_flow_format
    {
      id: "e#{id}",
      source: source_node.node_id,
      target: target_node.node_id,
      sourceHandle: source_output,
      targetHandle: target_input
    }
  end
end
