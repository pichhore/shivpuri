class AddFlagForProfilesWhichNeedsHelp < ActiveRecord::Migration
  def self.up
    add_column :profiles, :is_profile_need_help, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :is_profile_need_help
  end
end
