class CreateMapLahProductWithUsers < ActiveRecord::Migration
  def self.up
    exists = MapLahProductWithUser.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table map_lah_product_with_users..."
        create_table :map_lah_product_with_users do |t|
          t.column :first_name,               :string
          t.column :last_name,                :string
          t.column :email,                    :string
          t.column :product_name,             :string
          t.column :user_id, :string, :limit => 36, :null => false, :references => :users
          t.column :amps, :boolean, :default => false
          t.column :amps_gold, :boolean, :default => false

          t.timestamps
        end
      end
    end
  end

  def self.down
    exists = MapLahProductWithUser.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table map_lah_product_with_users..."
        drop_table :map_lah_product_with_users
      end
    end
  end
end
