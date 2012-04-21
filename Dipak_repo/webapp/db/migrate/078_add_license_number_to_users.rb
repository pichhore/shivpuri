class AddLicenseNumberToUsers < ActiveRecord::Migration
  def self.up
     transaction do
       puts "Adding license_number to table users..."
       add_column :users, :license_number, :string
       
       puts "Changing profile type permalinks to use _ instead of -"
       execute "update profile_types set name = replace(name,'-','_'), permalink = replace(permalink,'-','_')"
     end
  end

  def self.down
    transaction do
      puts "Removing license_number from table users..."
      remove_column :users, :license_number
      
      puts "Changing profile type permalinks back to using - instead of _"
      execute "update profile_types set name = replace(name,'_','-'), permalink = replace(permalink,'_','-')"
    end
  end
end
