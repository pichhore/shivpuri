class AddProfileNicknameFieldInProfileTable < ActiveRecord::Migration
  def self.up
    add_column :profiles, :profile_nickname, :string
    add_column :profiles, :is_profile_display_name_updated_by_user, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :profile_nickname
    remove_column :profiles, :is_profile_display_name_updated_by_user
  end
end
