class AddpaymentTransferStatusToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :payment_transfer_status, :boolean
    add_column :applications, :payment_transfer_date, :date
  end

  def self.down
    remove_column :applications, :payment_transfer_status
    remove_column :applications, :payment_transfer_date
  end
end
