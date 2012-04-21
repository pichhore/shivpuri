class AddPrivateNameToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :private_display_name, :string
  end

  def self.down
    remove_column :profiles, :private_display_name
  end
end
