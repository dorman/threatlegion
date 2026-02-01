class CreateVulnerabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :vulnerabilities do |t|
      t.string :cve_id
      t.decimal :cvss_score
      t.text :description
      t.datetime :published_date
      t.text :affected_products
      t.references :threat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
