class AddFieldForUserWhoComesFromReimHomePageInUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :is_user_comes_from_reim_home_page, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_user_comes_from_reim_home_page
  end
end
