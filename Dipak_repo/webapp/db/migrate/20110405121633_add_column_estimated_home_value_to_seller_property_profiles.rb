class AddColumnEstimatedHomeValueToSellerPropertyProfiles < ActiveRecord::Migration
  def self.up
    add_column :seller_property_profiles, :estimated_home_value, :integer
  end

  def self.down
    remove_column :seller_property_profiles, :estimated_home_value
  end
end
