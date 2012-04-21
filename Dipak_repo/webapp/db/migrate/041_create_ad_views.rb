class CreateAdViews < ActiveRecord::Migration
  def self.up
    exists = AdView.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table ad_views..."
        create_table :ad_views, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :ad_id, :string, :limit => 36, :null => false
          # going to prevent FK constraints since this is a sysadmin table
          # (don't want to break user functionality due to a sysadmin issue)
          t.column :user_id, :string, :limit => 36, :references=>nil
          t.column :profile_id, :string, :limit => 36, :references=>nil
          t.column :created_at, :datetime, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE ad_views ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = AdView.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table ad_views..."
        drop_table :ad_views
      end
    end
  end
end
