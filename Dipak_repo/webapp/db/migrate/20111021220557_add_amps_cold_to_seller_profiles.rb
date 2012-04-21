class AddAmpsColdToSellerProfiles < ActiveRecord::Migration
  def self.up
    add_column :seller_profiles, :amps_cold, :boolean, :default => false
  end

  def self.down
    remove_column :seller_profiles, :amps_cold
  end
end
