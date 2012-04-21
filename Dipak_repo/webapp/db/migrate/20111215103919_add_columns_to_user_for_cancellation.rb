class AddColumnsToUserForCancellation < ActiveRecord::Migration
  def self.up
    add_column :users, :cancellation_reason, :text
    add_column :users, :is_user_cancelled_membership, :boolean, :default => false
    add_column :users, :user_class_before_cancellation, :string
    add_column :users, :date_of_cancellation, :datetime
  end

  def self.down
    remove_column :users, :cancellation_reason
    remove_column :users, :is_user_cancelled_membership
    remove_column :users, :user_class_before_cancellation
    remove_column :users, :date_of_cancellation
  end
end
