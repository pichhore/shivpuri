class AddTypeAndAmountToLahProductPurchasedByUser < ActiveRecord::Migration
  def self.up
    add_column :lah_product_purchased_by_users, :product_type, :string
    add_column :lah_product_purchased_by_users, :amount, :string
  end

  def self.down
    remove_column :lah_product_purchased_by_users, :amount
    remove_column :lah_product_purchased_by_users, :product_type
  end
end
