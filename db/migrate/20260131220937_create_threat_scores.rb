class CreateThreatScores < ActiveRecord::Migration[7.2]
  def change
    create_table :threat_scores do |t|
      t.integer :score
      t.string :threat_level
      t.json :components
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
