class CreateProfileMatchesDetails < ActiveRecord::Migration

  def self.up
    exists = ProfileMatchesDetail.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_matches_details..."
        create_table "profile_matches_details", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :source_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :target_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :is_near, :boolean, :default => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_matches_details ADD PRIMARY KEY (id)"

        add_index :profile_matches_details, :source_profile_id
        add_index :profile_matches_details, :target_profile_id

      end
    end
  end

  def self.down
    exists = ProfileMatchesDetail.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_matches_details..."
        drop_table :profile_matches_details
      end
    end
  end
end
