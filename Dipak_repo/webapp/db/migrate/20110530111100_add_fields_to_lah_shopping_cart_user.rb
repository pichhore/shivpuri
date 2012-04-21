class AddFieldsToLahShoppingCartUser < ActiveRecord::Migration
  def self.up
    add_column :lah_shopping_cart_users, :user_id, :string, :limit => 36, :null => false, :references => :users
    add_column :lah_shopping_cart_users, :bundle_one, :boolean, :default => false
    add_column :lah_shopping_cart_users, :bundle_two, :boolean, :default => false
    add_column :lah_shopping_cart_users, :gold_upsell, :boolean, :default => false
    add_column :lah_shopping_cart_users, :reim_pro_upsell, :boolean, :default => false
  end

  def self.down
    remove_column :lah_shopping_cart_users, :user_id
    remove_column :lah_shopping_cart_users, :bundle_one
    remove_column :lah_shopping_cart_users, :bundle_two
    remove_column :lah_shopping_cart_users, :gold_upsell
    remove_column :lah_shopping_cart_users, :reim_pro_upsell
  end
end
