class AddLatLngToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :lat, :float
    add_column :addresses, :lng, :float
  end

  def self.down
    remove_column :addresses, :lat
    remove_column :addresses, :lng
  end
end
