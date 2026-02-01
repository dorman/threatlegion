class CreateWorkflowExecutions < ActiveRecord::Migration[7.2]
  def change
    create_table :workflow_executions do |t|
      t.references :workflow, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'pending' # pending, running, completed, failed
      t.datetime :started_at
      t.datetime :completed_at
      t.text :result_data # JSON data with results
      t.text :error_message
      t.integer :records_processed, default: 0

      t.timestamps
    end
  end
end
