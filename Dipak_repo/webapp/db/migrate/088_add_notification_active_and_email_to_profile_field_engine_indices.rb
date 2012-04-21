class AddNotificationActiveAndEmailToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :notification_active, :boolean, :default => 0
    add_column :profile_field_engine_indices, :notification_email, :string
  end

  def self.down
    remove_column :profile_field_engine_indices, :notification_email
    remove_column :profile_field_engine_indices, :notification_active
  end
end
