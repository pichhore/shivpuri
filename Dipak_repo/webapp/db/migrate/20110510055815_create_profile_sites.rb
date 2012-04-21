class CreateProfileSites < ActiveRecord::Migration
  def self.up
    exists = ProfileSite.table_exists? rescue false
    if !exists
      create_table :profile_sites do |t|
        t.string :profile_id, :limit => 36, :null => false, :references => :profiles
        t.integer :site_id, :null => false, :references => nil
        
        t.timestamps
      end
    end
  end
  
  def self.down
    drop_table :profile_sites
  end
end
