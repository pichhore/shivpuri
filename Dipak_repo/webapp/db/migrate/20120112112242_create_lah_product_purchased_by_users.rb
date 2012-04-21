class CreateLahProductPurchasedByUsers < ActiveRecord::Migration
  def self.up
    exists = LahProductPurchasedByUser.table_exists? rescue false
    if !exists
      transaction do
        create_table :lah_product_purchased_by_users, :id => false do |t|
          t.column :id, :string, :limit => 36
          t.column :user_id, :string, :limit => 36
          t.column :product_ids, :string
          t.column :product_name, :string
          
          t.timestamps
        end
      end
    end
  end

  def self.down
    exists = LahProductPurchasedByUser.table_exists? rescue false
    if exists
      transaction do
        drop_table :lah_product_purchased_by_users
      end
    end
  end
end
