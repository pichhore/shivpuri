class AddTotalDaysAndSubscriptionDateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_subscription_date, :datetime
    add_column :users, :subscription_days, :integer, :default => 0
  end

  def self.down
    remove_column :users, :last_subscription_date
    remove_column :users, :subscription_days
  end
end
