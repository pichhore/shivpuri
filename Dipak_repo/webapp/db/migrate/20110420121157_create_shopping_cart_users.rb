class CreateShoppingCartUsers < ActiveRecord::Migration
  def self.up
    exists = ShoppingCartUsers.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table shopping cart users..."
        create_table :shopping_cart_users do |t|
          t.column :first_name,                :string
          t.column :last_name,                 :string
          t.column :email,                     :string
          t.column :product_name,              :string
          t.column :quantity,                  :string
          t.timestamps
        end
      end
    end
  end

  def self.down
    exists = User.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table shopping cart users..."
        drop_table :shopping_cart_users
      end
    end
  end
end
