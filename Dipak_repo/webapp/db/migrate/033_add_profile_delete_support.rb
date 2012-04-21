class AddProfileDeleteSupport < ActiveRecord::Migration
  def self.up
    add_column :profile_views,              :deleted_at, :datetime
    add_column :profile_message_recipients, :deleted_at, :datetime
    add_column :profile_images,             :deleted_at, :datetime
    add_column :profile_fields,             :deleted_at, :datetime
    add_column :profile_favorites,          :deleted_at, :datetime
  end

  def self.down
    remove_column :profile_views,              :deleted_at
    remove_column :profile_message_recipients, :deleted_at
    remove_column :profile_images,             :deleted_at
    remove_column :profile_fields,             :deleted_at
    remove_column :profile_favorites,          :deleted_at
  end
end
