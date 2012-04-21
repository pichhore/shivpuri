class RemoveLandlordFromApplication < ActiveRecord::Migration
  def self.up
    remove_column :applications, :landlord_id
  end

  def self.down
    add_column :applications, :landlord_id, :integer
  end
end
