class CreateSellerProfiles < ActiveRecord::Migration
  def self.up
    exists = SellerProfile.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table seller_profiles..."
          create_table :seller_profiles, :id => false do |t|
            t.column :id,                        :string, :limit => 36, :null => false
            t.column :user_id,                   :string, :limit => 36, :null => false, :references => :users
            t.column :seller_website_id,         :string, :limit => 36, :null => false, :references => :seller_websites
            t.column :first_name,                :string
            t.column :last_name,                 :string
            t.column :phone,                     :string
            t.column :alternate_phone,           :string
            t.column :email,                     :string
            t.column :city,                      :string
            t.column :state,                     :string
            t.timestamps
          end
        puts "Setting primary key"
        execute "ALTER TABLE seller_profiles ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SellerProfile.table_exists? rescue false
      if exists
        drop_table :seller_profiles
      end
  end
end
