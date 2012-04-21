class ChangeColumnFromMapLahProductWithUser < ActiveRecord::Migration
  def self.up
    change_column_default(:map_lah_product_with_users, :blueprint, true)
  end

  def self.down
  end
end
