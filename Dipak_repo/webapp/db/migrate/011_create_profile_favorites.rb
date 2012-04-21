class CreateProfileFavorites < ActiveRecord::Migration
  def self.up
    exists = ProfileFavorite.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_favorites..."
        create_table "profile_favorites", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :target_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_favorites ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ProfileFavorite.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_favorites..."
        drop_table :profile_favorites
      end
    end
  end
end
