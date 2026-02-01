class CreateThreats < ActiveRecord::Migration[7.2]
  def change
    create_table :threats do |t|
      t.string :name
      t.string :threat_type
      t.string :severity
      t.text :description
      t.string :status
      t.datetime :first_seen
      t.datetime :last_seen
      t.integer :confidence_score
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
