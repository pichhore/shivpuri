class AddCountForFailedUserInUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :user_login_count_after_failed_payment, :integer
  end

  def self.down
    remove_column :users, :user_login_count_after_failed_payment
  end
end
