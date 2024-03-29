class AddColumnIsNewToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :is_new, :boolean, :default => true
    Profile.reset_column_information
    Profile.all.each do |profile|
      profile.is_new = false
      profile.send(:update_without_callbacks)
    end
  end

  def self.down
    remove_column :profiles, :is_new
  end
end
