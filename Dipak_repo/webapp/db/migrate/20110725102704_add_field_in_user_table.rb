class AddFieldInUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :is_user_have_access_to_reim, :boolean, :default => true
  end

  def self.down
    remove_column :users, :is_user_have_access_to_reim
  end
end
