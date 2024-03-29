class AddSomeFieldsToSellerPropertyProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_property_profiles, :subdivision, :string
    add_column :seller_property_profiles, :lot_size, :string
    add_column :seller_property_profiles,:out_bldgs ,:string
    add_column :seller_property_profiles,:occupied_by,:string
    add_column :seller_property_profiles,:occupied_rent,:integer
    add_column :seller_property_profiles,:occupied_lease_up,:string
    add_column :seller_property_profiles,:min_price,:integer
    add_column :seller_property_profiles,:tax_app_values,:integer
    add_column :seller_property_profiles,:arv,:integer
    add_column :seller_property_profiles,:home_listed_agent,:string
    add_column :seller_property_profiles,:home_listed_expiration_date,:datetime
  end

  def self.down
    remove_column :seller_property_profiles, :subdivision, :string
    remove_column :seller_property_profiles, :lot_size, :string
    remove_column :seller_property_profiles,:out_bldgs ,:string
    remove_column :seller_property_profiles,:occupied_by,:string
    remove_column :seller_property_profiles,:occupied_rent,:integer
    remove_column :seller_property_profiles,:occupied_lease_up,:string
    remove_column :seller_property_profiles,:min_price,:integer
    remove_column :seller_property_profiles,:tax_app_values,:integer
    remove_column :seller_property_profiles,:arv,:integer
    remove_column :seller_property_profiles,:home_listed_agent,:string
    remove_column :seller_property_profiles,:home_listed_expiration_date,:datetime
  end
end
