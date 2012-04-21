class InsertValueInContractBuyerType < ActiveRecord::Migration
  def self.up
    execute("insert into contract_buyer_types values(1,'ME','Me')");
    execute("insert into contract_buyer_types values(2,'MB','My Buyer')");
    execute("insert into contract_buyer_types values(3,'WI','Write In')");
  end

  def self.down
  end
end
