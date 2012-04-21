class AddProfileToApplication < ActiveRecord::Migration
  def self.up
    add_column :applications, :profile_id, :integer
  end

  def self.down
    remove_column :applications, :profile_id
  end
end
