class CreateProfileViews < ActiveRecord::Migration
  def self.up
    exists = ProfileView.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_views..."
        create_table "profile_views", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :viewed_by_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_views ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ProfileView.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_views..."
        drop_table :profile_views
      end
    end
  end
end
