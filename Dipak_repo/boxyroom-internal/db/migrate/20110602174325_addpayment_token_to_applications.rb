class AddpaymentTokenToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :payment_token, :string
  end

  def self.down
    remove_column :applications, :payment_token
  end
end
