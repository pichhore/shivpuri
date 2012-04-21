class AddCustomerRecordInUser < ActiveRecord::Migration
  def self.up
    add_column :users,:customer_record,:integer
  end

  def self.down
    remove_column :users,:customer_record
  end
end
