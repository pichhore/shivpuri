class AddReVolutionColumnToMapLahProductWithUser < ActiveRecord::Migration
  def self.up
     add_column :map_lah_product_with_users, :re_volution, :boolean, :default => false
  end

  def self.down
    remove_column :map_lah_product_with_users, :re_volution
  end
end
