class CreateContractSellerTypes < ActiveRecord::Migration
 def self.up
    exists = ContractSellerType.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table contract_seller_types..."
        create_table :contract_seller_types do |t|
          t.column :code, :string, :null => false
          t.column :name, :string, :null => false
       end
      end
    end
  end

  def self.down
    exists = ContractSellerType.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table contract_seller_types..."
        drop_table :contract_seller_types
      end
    end
  end
end
