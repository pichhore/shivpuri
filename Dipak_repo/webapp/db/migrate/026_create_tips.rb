class CreateTips < ActiveRecord::Migration
  def self.up
    exists = Tip.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table tips..."
        create_table "tips", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :tip_text, :string
          t.column :target_page, :string
          t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE tips ADD PRIMARY KEY (id)"

        puts "Created default entries"
        Tip.create!({ :tip_text=>"The 'New' tab shows new property matches since your last visit", :target_page=>"buyer_dashboard"})
        Tip.create!({ :tip_text=>"Click the 'Star' to add or remove this property from your Favorites", :target_page=>"show_owner"})
        Tip.create!({ :tip_text=>"Uploaded an image of your home yet? Click Upload/Manage Photos under the Navigation Menu", :target_page=>"owner_dashboard"})
        Tip.create!({ :tip_text=>"You can contact buyers as a group from your Property Dashboard", :target_page=>"show_buyer"})
      end
    end
  end

  def self.down
    exists = Tip.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table tips..."
        drop_table :tips
      end
    end
  end
end
