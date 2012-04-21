class AddIndexLatLngInAddresses < ActiveRecord::Migration
  def self.up
    add_index  :addresses, [:lat, :lng]
  end

  def self.down
    remove_index  :addresses, [:lat, :lng]
  end

end
