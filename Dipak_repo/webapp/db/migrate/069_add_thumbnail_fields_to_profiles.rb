class AddThumbnailFieldsToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :default_photo_url, :string
    add_column :profiles, :default_std_thumbnail_url, :string
    add_column :profiles, :default_micro_thumbnail_url, :string
  end

  def self.down
    remove_column :profiles, :default_photo_url
    remove_column :profiles, :default_std_thumbnail_url
    remove_column :profiles, :default_micro_thumbnail_url
  end
end
