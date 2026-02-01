class CreateWorkflowNodes < ActiveRecord::Migration[7.2]
  def change
    create_table :workflow_nodes do |t|
      t.references :workflow, null: false, foreign_key: true
      t.string :node_type, null: false # 'service', 'filter', 'transform', 'output'
      t.string :service_name # e.g., 'abuse_ch', 'abuseipdb'
      t.string :label
      t.decimal :position_x, precision: 10, scale: 2, default: 0
      t.decimal :position_y, precision: 10, scale: 2, default: 0
      t.text :config # JSON config for the node
      t.string :node_id # Unique ID for the node in the visual editor

      t.timestamps
    end
    
    add_index :workflow_nodes, :node_id
  end
end
