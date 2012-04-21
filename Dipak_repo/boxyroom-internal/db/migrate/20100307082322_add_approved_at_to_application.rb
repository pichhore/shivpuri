class AddApprovedAtToApplication < ActiveRecord::Migration
  def self.up
    add_column :applications, :approved_at, :datetime
  end

  def self.down
    remove_column :applications, :approved_at
  end
end
