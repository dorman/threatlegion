class DropThreatFeeds < ActiveRecord::Migration[7.2]
  def up
    drop_table :threat_feeds, if_exists: true
  end

  def down
    create_table :threat_feeds do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :feed_type
      t.boolean :enabled, default: true
      t.integer :refresh_interval, default: 3600
      t.datetime :last_fetched_at
      t.json :config

      t.timestamps
    end
  end
end
