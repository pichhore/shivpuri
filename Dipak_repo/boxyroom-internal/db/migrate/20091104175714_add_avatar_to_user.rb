class AddAvatarToUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :profile_image_url
    add_column :users, :avatar_file_name, :string
    add_column :users, :avatar_content_type, :string
    add_column :users, :avatar_file_size, :integer
    add_column :users, :avatar_updated_at, :datetime
  end

  def self.down
    add_column :users, :profile_image_url, :string
    remove_column :users, :avatar_file_name
    remove_column :users, :avatar_content_type
    remove_column :users, :avatar_file_size
    remove_column :users, :avatar_updated_at
  end
end
