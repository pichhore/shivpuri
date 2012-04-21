class AddMailNumberToRetailBuyerProfile < ActiveRecord::Migration
  def self.up
    add_column :retail_buyer_profiles, :mail_number, :integer,:default=>0
  end

  def self.down
    remove_column :retail_buyer_profiles, :mail_number
  end
end
