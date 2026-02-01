class CreateCachedMaliciousIps < ActiveRecord::Migration[7.2]
  def change
    create_table :cached_malicious_ips do |t|
      t.string :ip_address
      t.string :country_code
      t.integer :abuse_confidence_score
      t.datetime :last_reported_at
      t.string :source
      t.json :metadata
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
