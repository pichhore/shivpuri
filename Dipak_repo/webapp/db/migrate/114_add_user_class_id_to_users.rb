class AddUserClassIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :user_class_id, :integer
  end

  def self.down
    remove_column :users, :user_class_id
  end
end
