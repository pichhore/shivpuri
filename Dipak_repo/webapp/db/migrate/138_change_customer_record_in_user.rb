class ChangeCustomerRecordInUser < ActiveRecord::Migration
  def self.up
   rename_column :users, :customer_record,:number_of_territory
  end

  def self.down
   rename_column :users,:number_of_territory, :customer_record
  end
end
