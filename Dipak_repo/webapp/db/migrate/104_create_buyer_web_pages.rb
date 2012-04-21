class CreateBuyerWebPages < ActiveRecord::Migration
  def self.up
    exists = BuyerWebPage.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table buyer_web_pages..."
        create_table "buyer_web_pages", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_territory_id, :string, :limit => 36
            t.column :tag_line, :string
            t.column :header, :string
            t.column :opening_text, :string
            t.column :permalink_text, :string
            t.column :active, :boolean
        end

        puts "Setting primary key"
        execute "ALTER TABLE buyer_web_pages ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :buyer_web_pages
  end
end
