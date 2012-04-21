class AddTransactionIdToApplication < ActiveRecord::Migration
  def self.up
    add_column :applications, :transaction_id, :string
  end

  def self.down
    remove_column :applications, :transaction_id
  end
end
