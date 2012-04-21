class AddFieldsIntoSellerPropertyProfile < ActiveRecord::Migration
  def self.up
    add_column          :seller_property_profiles, :foundation_type,              :string
    add_column          :seller_property_profiles, :roof_age,                     :string
    add_column          :seller_property_profiles, :mobile_or_manufactured_home,  :string
    add_column          :seller_property_profiles, :property_conditions,          :string
    add_column          :seller_property_profiles, :repairs_needed,               :text
    add_column          :seller_property_profiles, :mortgage_current,             :string
    add_column          :seller_property_profiles, :last_payment_made,            :string
    add_column          :seller_property_profiles, :asking_home_price,            :string
    add_column          :seller_property_profiles, :home_listed,                  :string
    add_column          :seller_property_profiles, :city,                         :string
    add_column          :seller_property_profiles, :state,                        :string
    add_column          :seller_property_profiles, :selling_reason,               :text
    remove_column       :seller_profiles,          :city
    remove_column       :seller_profiles,          :state
  end

  def self.down
    remove_column       :seller_property_profiles, :foundation_type
    remove_column       :seller_property_profiles, :roof_age
    remove_column       :seller_property_profiles, :mobile_or_manufactured_home
    remove_column       :seller_property_profiles, :property_conditions
    remove_column       :seller_property_profiles, :repairs_needed
    remove_column       :seller_property_profiles, :mortgage_current
    remove_column       :seller_property_profiles, :last_payment_made
    remove_column       :seller_property_profiles, :asking_home_price
    remove_column       :seller_property_profiles, :home_listed
    remove_column       :seller_property_profiles, :selling_reason
    remove_column       :seller_property_profiles, :city
    remove_column       :seller_property_profiles, :state
    add_column          :seller_profiles,          :city,                         :string
    add_column          :seller_profiles,          :state,                        :string
  end
end
