class ChangeBathroomsToBoolean < ActiveRecord::Migration
  def self.up
    remove_column :properties, :bathrooms
    add_column :properties, :bathroom, :boolean
  end

  def self.down
    remove_column :properties, :bathroom
    add_column :properties, :bathrooms, :integer
  end
end
