class AddDefaultPhotoToProfileImages < ActiveRecord::Migration
  def self.up
    add_column :profile_images, :default_photo, :boolean
  end

  def self.down
    remove_column :profile_images, :default_photo
  end
end
