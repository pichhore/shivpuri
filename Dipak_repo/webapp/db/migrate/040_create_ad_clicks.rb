class CreateAdClicks < ActiveRecord::Migration
  def self.up
    exists = AdClick.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table ad_clicks..."
        create_table :ad_clicks, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :ad_id, :string, :limit => 36, :null => false
          # going to prevent FK constraints since this is a sysadmin table
          # (don't want to break user functionality due to a sysadmin issue)
          t.column :user_id, :string, :limit => 36, :references=>nil
          t.column :profile_id, :string, :limit => 36, :references=>nil
          t.column :created_at, :datetime, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE ad_clicks ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = AdClick.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table ad_clicks..."
        drop_table :ad_clicks
      end
    end
  end
end
