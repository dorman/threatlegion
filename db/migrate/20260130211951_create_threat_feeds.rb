class CreateThreatFeeds < ActiveRecord::Migration[7.2]
  def change
    create_table :threat_feeds do |t|
      t.string :name
      t.string :url
      t.string :feed_type
      t.boolean :enabled
      t.datetime :last_fetched
      t.integer :refresh_interval

      t.timestamps
    end
  end
end
