class AddFieldsInLahShoppingCartUser < ActiveRecord::Migration
  def self.up
    add_column :lah_shopping_cart_users, :product_id_detail, :string
    add_column :lah_shopping_cart_users, :customer_id_detail, :string
  end

  def self.down
    remove_column :lah_shopping_cart_users, :product_id_detail, :string
    remove_column :lah_shopping_cart_users, :customer_id_detail, :string
  end
end
