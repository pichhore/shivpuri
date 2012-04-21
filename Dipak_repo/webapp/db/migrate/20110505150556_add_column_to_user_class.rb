class AddColumnToUserClass < ActiveRecord::Migration
  def self.up
    add_column :user_classes,:user_type_name,:string
  end

  def self.down
    remove_column :user_classes,:user_type_name
  end
end
