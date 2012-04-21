class CreateProfileMatchesCounts < ActiveRecord::Migration
  def self.up
    exists = ProfileMatchesCount.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_matches_counts..."
        create_table :profile_matches_counts, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_id, :string, :limit => 36, :null => false
          t.column :count, :integer, :default => 0
          t.column :status, :boolean, :default => 0
        end
        puts "Setting primary key"
        execute "ALTER TABLE profile_matches_counts ADD PRIMARY KEY (id)"
        
        add_index :profile_matches_counts, :profile_id

        pfei = ProfileFieldEngineIndex.find_by_sql("SELECT * FROM `profile_field_engine_indices` as pfei INNER JOIN `profiles` ON `profiles`.id = pfei.profile_id and profiles.deleted_at is null INNER JOIN `users` ON `users`.id = `profiles`.user_id WHERE ((zip_code <> 0) && users.activation_code is null and pfei.status='active') GROUP BY pfei.profile_id;").collect{|pfei| pfei.profile_id}
        Profile.find(:all, :conditions => ["id in (?)", pfei]).each { |p|  
          ProfileMatchesCount.create(:profile_id => p.id, :count => -1)
          }

      end
    end
  end
  
  def self.down
    exists = ProfileMatchesCount.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_matches_counts..."
        drop_table :profile_matches_counts
      end
    end
  end
end
