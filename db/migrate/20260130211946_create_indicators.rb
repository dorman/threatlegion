class CreateIndicators < ActiveRecord::Migration[7.2]
  def change
    create_table :indicators do |t|
      t.string :indicator_type
      t.string :value
      t.references :threat, null: false, foreign_key: true
      t.datetime :first_seen
      t.datetime :last_seen
      t.integer :confidence
      t.text :tags
      t.string :source

      t.timestamps
    end
  end
end
