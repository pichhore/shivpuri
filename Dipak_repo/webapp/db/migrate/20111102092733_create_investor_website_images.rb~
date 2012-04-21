class CreateInvestorWebsiteImages < ActiveRecord::Migration
  def self.up
    exists = InvestorWebsiteImage.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table user_company_images..."
        create_table "investor_website_images", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :investor_website_id, :string, :limit => 36
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
        execute "ALTER TABLE investor_website_images ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    drop_table :investor_website_images
  end
end
