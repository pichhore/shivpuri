class ChangeDataTypeForPaymentTransferDate < ActiveRecord::Migration
  def self.up
    change_column :applications, :payment_transfer_date, :datetime
  end

  def self.down
    change_column :applications, :payment_transfer_date, :date
  end
end
