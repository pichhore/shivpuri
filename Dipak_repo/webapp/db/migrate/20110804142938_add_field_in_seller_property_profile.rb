class AddFieldInSellerPropertyProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_property_profiles, :responder_sequence_subscription, :boolean, :default=>true
  end

  def self.down
    remove_column :seller_property_profiles, :responder_sequence_subscription
  end
end
