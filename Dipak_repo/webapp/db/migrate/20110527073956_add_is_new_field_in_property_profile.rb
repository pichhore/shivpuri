class AddIsNewFieldInPropertyProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_property_profiles, :is_new, :boolean, :default => true
  end

  def self.down
    remove_column :seller_property_profiles, :is_new
  end
end
