class CreateFeeds < ActiveRecord::Migration
  def self.up
    exists = Feed.table_exists? rescue false
    if !exists
      create_table :feeds do |t|
        t.column :user_id, :string, :limit => 36
        t.column :territory_id, :string
        t.column :activity_id, :integer, :references => nil
        t.timestamps
      end
    end
  end

  def self.down
    drop_table :feeds
  end
end
