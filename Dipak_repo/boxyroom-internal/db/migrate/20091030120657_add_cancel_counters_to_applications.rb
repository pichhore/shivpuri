class AddCancelCountersToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :landlord_cancel, :boolean, :default => false
    add_column :applications, :tenant_cancel, :boolean, :default => false
  end

  def self.down
    remove_column :applications, :landlord_cancel
    remove_column :applications, :tenant_cancel

  end
end
