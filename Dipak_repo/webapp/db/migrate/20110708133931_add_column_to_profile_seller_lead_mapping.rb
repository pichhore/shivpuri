class AddColumnToProfileSellerLeadMapping < ActiveRecord::Migration
  def self.up
    add_column :profile_seller_lead_mappings,:seller_property_profile_id, :string, :limit => 36, :null => false,:references => :seller_property_profiles
  end

  def self.down
    remove_column :profile_seller_lead_mappings,:seller_property_profile_id
  end
end
