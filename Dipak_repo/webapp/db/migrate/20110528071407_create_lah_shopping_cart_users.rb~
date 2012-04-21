class CreateLahShoppingCartUsers < ActiveRecord::Migration
  def self.up
    exists = LahShoppingCartUser.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table lah_shopping_cart_users..."
        create_table :lah_shopping_cart_users do |t|
          t.column :first_name,               :string
          t.column :last_name,                :string
          t.column :email,                    :string
          t.column :product_name,             :string
          t.column :quantity,                 :string

          t.timestamps
        end
      end
    end
  end

  def self.down
    exists = LahShoppingCartUser.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table lah_shopping_cart_users..."
        drop_table :lah_shopping_cart_users
      end
    end
  end
end