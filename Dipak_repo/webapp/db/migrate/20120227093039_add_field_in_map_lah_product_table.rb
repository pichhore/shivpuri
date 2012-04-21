class AddFieldInMapLahProductTable < ActiveRecord::Migration
  def self.up
     add_column :map_lah_product_with_users, :allinone, :boolean, :default => false
     add_column :users, :is_user_moved_to_new_pro_bucket, :boolean, :default => false
  end

  def self.down
     remove_column :map_lah_product_with_users, :allinone
     remove_column :users, :is_user_moved_to_new_pro_bucket
  end
end
