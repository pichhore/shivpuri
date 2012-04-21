class CreateSiteUsers < ActiveRecord::Migration
  def self.up
    exists = SiteUser.table_exists? rescue false
    if !exists
      create_table :site_users do |t|
        t.column :user_id, :string, :limit => 36, :null => false, :references => :users
        t.column :site_id, :integer, :null => false, :references => nil
        
        t.timestamps
      end
    end
  end

  def self.down
    drop_table :site_users
  end
end
