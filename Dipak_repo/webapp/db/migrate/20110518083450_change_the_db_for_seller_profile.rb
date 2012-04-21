class ChangeTheDbForSellerProfile < ActiveRecord::Migration
  def self.up
    remove_column     :responder_sequence_assign_to_seller_profiles,   :seller_profile_id
    add_column        :responder_sequence_assign_to_seller_profiles,   :seller_property_profile_id,         :string, :limit => 36, :null => false, :references => :seller_property_profiles
  end

  def self.down
    remove_column     :responder_sequence_assign_to_seller_profiles,   :seller_property_profile_id
    add_column        :responder_sequence_assign_to_seller_profiles,   :seller_profile_id,                  :string, :limit => 36, :null => false, :references => :seller_profiles
  end
end
