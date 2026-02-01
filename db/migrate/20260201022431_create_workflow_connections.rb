class CreateWorkflowConnections < ActiveRecord::Migration[7.2]
  def change
    create_table :workflow_connections do |t|
      t.references :workflow, null: false, foreign_key: true
      t.references :source_node, null: false, foreign_key: { to_table: :workflow_nodes }
      t.references :target_node, null: false, foreign_key: { to_table: :workflow_nodes }
      t.string :source_output
      t.string :target_input

      t.timestamps
    end
  end
end
