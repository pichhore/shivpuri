class AddFieldsInMapLahProductsInUsersTable < ActiveRecord::Migration
  def self.up
     add_column :map_lah_product_with_users, :wholesaling, :boolean, :default => false
     add_column :map_lah_product_with_users, :blueprint, :boolean, :default => false
  end

  def self.down
     remove_column :map_lah_product_with_users, :wholesaling
     remove_column :map_lah_product_with_users, :blueprint
  end
end
