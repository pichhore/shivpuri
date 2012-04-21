class AddColumnSpamReasonToProfileMessage < ActiveRecord::Migration
  def self.up
    add_column :profile_messages, :spam_reason, :text
  end

  def self.down
    remove_column :profile_messages, :spam_reason
  end
end
