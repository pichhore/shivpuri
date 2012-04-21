class AddIsNewColumnToRetailBuyerProfiles < ActiveRecord::Migration
  def self.up
    add_column :retail_buyer_profiles, :is_new, :boolean, :default => true
  end

  def self.down
    remove_column :retail_buyer_profiles, :is_new
  end
end
