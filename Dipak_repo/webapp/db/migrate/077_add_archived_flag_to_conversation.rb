class AddArchivedFlagToConversation < ActiveRecord::Migration
  def self.up
    add_column :profile_message_recipients, :archived, :boolean
  end

  def self.down
    remove_column :profile_message_recipients, :archived
  end
end
