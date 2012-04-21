class AddNotificationPhoneToBuyerProfile < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :notification_phone, :string
  end

  def self.down
    remove_column :profile_field_engine_indices, :notification_phone
  end
end
