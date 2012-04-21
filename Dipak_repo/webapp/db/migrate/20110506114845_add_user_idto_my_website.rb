class AddUserIdtoMyWebsite < ActiveRecord::Migration
  def self.up
    add_column :my_websites,:user_id,:string,:references=>:users
  end

  def self.down
    remove_column :my_websites,:user_id
  end
end
