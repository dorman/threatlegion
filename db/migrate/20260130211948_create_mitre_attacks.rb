class CreateMitreAttacks < ActiveRecord::Migration[7.2]
  def change
    create_table :mitre_attacks do |t|
      t.string :tactic
      t.string :technique
      t.string :technique_id
      t.text :description
      t.references :threat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
