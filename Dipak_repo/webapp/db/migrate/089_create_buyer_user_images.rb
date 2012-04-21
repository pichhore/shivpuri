class CreateBuyerUserImages < ActiveRecord::Migration
  def self.up

    exists = BuyerUserImage.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table buyer_user_images..."
        create_table "buyer_user_images", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_id, :string, :limit => 36, :null => false, :references => :users
            t.column :created_at, :datetime
            t.column :parent_id, :string, :limit => 36, :references => nil
            t.column :content_type, :string
            t.column :filename, :string    
            t.column :thumbnail, :string 
            t.column :size, :integer
            t.column :width, :integer
            t.column :height, :integer
        end

        puts "Setting primary key"
        execute "ALTER TABLE buyer_user_images ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :buyer_user_images
  end
end
