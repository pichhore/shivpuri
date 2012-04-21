class AddpaymentTransferMailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :payment_transfer_mail, :string
  end

  def self.down
    remove_column :users, :payment_transfer_mail
  end
end
