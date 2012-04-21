class CreateContractBuyerTypes < ActiveRecord::Migration
  def self.up
    exists = ContractBuyerType.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table contract_buyer_types..."
        create_table :contract_buyer_types do |t|
          t.column :code, :string, :null => false
          t.column :name, :string, :null => false
       end
      end
    end
  end

  def self.down
    exists = ContractBuyerType.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table contract_buyer_types..."
        drop_table :contract_buyer_types
      end
    end
  end
end
