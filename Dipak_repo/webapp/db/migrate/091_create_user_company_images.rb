class CreateUserCompanyImages < ActiveRecord::Migration
  def self.up
    exists = UserCompanyImage.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table user_company_images..."
        create_table "user_company_images", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_company_info_id, :string, :limit => 36, :null => false
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
        execute "ALTER TABLE user_company_images ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :user_company_images
  end
end
