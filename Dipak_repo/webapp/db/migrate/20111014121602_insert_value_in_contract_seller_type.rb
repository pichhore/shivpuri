class InsertValueInContractSellerType < ActiveRecord::Migration
  def self.up
    execute("insert into contract_seller_types values(1,'ME','Me')");
    execute("insert into contract_seller_types values(2,'OWN','Owner')");
    execute("insert into contract_seller_types values(3,'WI','Write In')");
  end

  def self.down
  end
end
