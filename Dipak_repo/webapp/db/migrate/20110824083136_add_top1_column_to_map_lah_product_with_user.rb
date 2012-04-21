class AddTop1ColumnToMapLahProductWithUser < ActiveRecord::Migration
  def self.up
    add_column :map_lah_product_with_users, :top1, :boolean, :default => false
  end

  def self.down
    remove_column :map_lah_product_with_users, :top1
  end
end
