class AddProfileMessageIdToProfileMessageRecipients < ActiveRecord::Migration
  def self.up
    add_column :profile_message_recipients, :profile_message_id, :string, :limit => 36, :null => false, :references => :profile_messages
  end

  def self.down
    remove_column :profile_message_recipients, :profile_message_id
  end
end
