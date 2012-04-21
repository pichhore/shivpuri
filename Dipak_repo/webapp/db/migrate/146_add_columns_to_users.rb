class AddColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :investor_focus, :string
    add_column :users, :investing_since, :date
    add_column :users, :about_me, :text
    add_column :users, :real_estate_experience, :text
  end

  def self.down
    remove_column :users, :real_estate_experience
    remove_column :users, :about_me
    remove_column :users, :investing_since
    remove_column :users, :investor_focus
  end
end
