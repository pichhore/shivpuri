class AddAdminColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :admin_flag, :boolean, :default=>false, :null=>false
  end

  def self.down
    drop_column :users, :admin_flag
  end
end
