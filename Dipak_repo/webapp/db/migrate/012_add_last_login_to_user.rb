class AddLastLoginToUser < ActiveRecord::Migration
  def self.up
    puts "Adding last_login_at to table users..."
    add_column :users, :last_login_at, :datetime
    puts "Adding previous_login_at to table users..."
    add_column :users, :previous_login_at, :datetime
  end

  def self.down
    puts "Removing last_login_at to table users..."
    remove_column :users, :last_login_at, :datetime
    puts "Removing previous_login_at to table users..."
    remove_column :users, :previous_login_at, :datetime
  end
end
