class AddColumnToSellerProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_profiles, :bird_dog_locator, :string
  end

  def self.down
    remove_column :seller_profiles, :bird_dog_locator
  end
end
