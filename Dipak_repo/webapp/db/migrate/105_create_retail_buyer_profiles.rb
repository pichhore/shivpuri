class CreateRetailBuyerProfiles < ActiveRecord::Migration
  def self.up
    exists = RetailBuyerProfile.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table retail_buyer_profiles..."
        create_table "retail_buyer_profiles", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_territory_id, :string, :limit => 36
            t.column :first_name, :string
            t.column :last_name, :string
            t.column :phone, :string
            t.column :alternate_phone, :string
            t.column :email_address, :string
            t.column :active, :boolean
            t.column :activation_code, :string
            t.column :activated_at, :datetime
            t.column :updated_at, :datetime
            t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE retail_buyer_profiles ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :retail_buyer_profiles
  end
end
