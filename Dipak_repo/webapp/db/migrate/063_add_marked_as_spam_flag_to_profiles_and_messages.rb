class AddMarkedAsSpamFlagToProfilesAndMessages < ActiveRecord::Migration
  def self.up
    add_column :profiles, :marked_as_spam, :boolean, :default => false
    add_column :profile_messages, :marked_as_spam, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :marked_as_spam
    remove_column :profile_messages, :marked_as_spam
  end
end
