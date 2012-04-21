class CreateProfileMatches < ActiveRecord::Migration

  def self.up
    exists = ProfileMatch.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_matches..."
        create_table "profile_matches", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :source_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :target_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_matches ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ProfileMatch.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_matches..."
        drop_table :profile_matches
      end
    end
  end
end
