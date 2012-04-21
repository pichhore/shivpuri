class AddProfileImageSortOrderColumnToIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :has_profile_image, :boolean, :null => false, :default=>false
  end

  def self.down
    remove_column :profile_field_engine_indices, :has_profile_image
  end
end
