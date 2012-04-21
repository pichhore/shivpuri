class CreateShoppingCartUserDetails < ActiveRecord::Migration
  def self.up
    create_table :shopping_cart_user_details do |t|
      t.column :shopping_cart_customer_id_detail, :string
      t.column :user_name, :string
      t.column :user_id, :string, :limit => 36, :references => :users
      t.column :user_email, :string
      t.column :shopping_cart_name, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :shopping_cart_user_details
  end
end