class AddIsNearColumnintoProfileFavourite < ActiveRecord::Migration
  def self.up
    add_column :profile_favorites, :is_near, :boolean
  end

  def self.down
    remove_column :profile_favorites, :is_near
  end
end
