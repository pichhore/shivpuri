class AddCountryColumnToSellerPropertyProfile < ActiveRecord::Migration
  def self.up
    add_column "seller_property_profiles", "country", :string , :default => "US"
  end

  def self.down
    remove_column "seller_property_profiles", "country"
  end
end
