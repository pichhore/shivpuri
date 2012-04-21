class AddReiMarketingDepartmentColumnToMapLahProductWithUser < ActiveRecord::Migration
  def self.up
    add_column :map_lah_product_with_users, :rei_mkt_dept, :boolean, :default => false
  end

  def self.down
    remove_column :map_lah_product_with_users, :rei_mkt_dept
  end
end
