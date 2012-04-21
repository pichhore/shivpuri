class AddFieldsInUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :is_user_have_failed_payment, :boolean, :default => false
    add_column :users, :failed_payment_date, :string
    execute "UPDATE users SET is_user_have_failed_payment=1 WHERE is_user_have_access_to_reim=0"
  end

  def self.down
    remove_column :users, :is_user_have_failed_payment
    remove_column :users, :failed_payment_date
  end
end
