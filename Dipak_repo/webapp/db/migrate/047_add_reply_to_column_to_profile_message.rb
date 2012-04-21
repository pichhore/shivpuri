class AddReplyToColumnToProfileMessage < ActiveRecord::Migration
  def self.up
    add_column :profile_messages, :reply_to_profile_message_id, :string, :limit => 36, :references=>:profile_messages
  end

  def self.down
    drop_column :profile_messages, :reply_to_profile_message_id
  end
end
