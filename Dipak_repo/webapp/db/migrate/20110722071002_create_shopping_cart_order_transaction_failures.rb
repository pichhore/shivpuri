class CreateShoppingCartOrderTransactionFailures < ActiveRecord::Migration
  def self.up
    exists = ShoppingCartOrderTransactionFailure.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table shopping_cart_order_transaction_failures..."
        create_table :shopping_cart_order_transaction_failures, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :user_id, :string, :limit => 36, :null => false, :references => :users
          t.column :shopping_cart_name, :string
          t.column :shopping_cart_customer_id_detail, :string
          t.column :shopping_cart_product_id_detail, :string
          t.column :shopping_cart_product_name, :string
          t.column :shopping_cart_order_id_detail, :string
          t.column :shopping_cart_user_email, :string

          t.timestamps
        end
        puts "Setting primary key"
        execute "ALTER TABLE shopping_cart_order_transaction_failures ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ShoppingCartOrderTransactionFailure.table_exists? rescue false
    if exists
      drop_table :shopping_cart_order_transaction_failures
    end
  end
end