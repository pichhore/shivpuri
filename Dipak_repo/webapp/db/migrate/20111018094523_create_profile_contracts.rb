class CreateProfileContracts < ActiveRecord::Migration
  def self.up
    create_table :profile_contracts do |t|
      t.string :seller_property_profile_id
      t.integer :contract_buyer_type_id
      t.integer :contract_seller_type_id
      t.string :seller_write_in
      t.string :buyer_write_in
      t.string :my_buyer
      t.text :contract

      t.timestamps
    end
  end

  def self.down
    drop_table :profile_contracts
  end
end
