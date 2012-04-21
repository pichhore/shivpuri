class ChangeBathColumnInSellerPropertyProfile < ActiveRecord::Migration
  def self.up
    change_column :seller_property_profiles, :baths, :integer
  end

  def self.down
    change_column :seller_property_profiles, :baths, :float
  end
end
