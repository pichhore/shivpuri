class RemoveProfileIdFromApplication < ActiveRecord::Migration
  def self.up
    remove_column :applications, :profile_id
  end

  def self.down
    add_column :applications, :profile_id, :integer
  end
end
