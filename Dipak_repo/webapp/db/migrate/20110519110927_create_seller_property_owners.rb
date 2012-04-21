class CreateSellerPropertyOwners < ActiveRecord::Migration
  def self.up
    exists = SellerPropertyOwner.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table seller_property_owners..."
        create_table :seller_property_owners, :id => false do |t|

          t.column :id,                        :string, :limit => 36, :null => false
          t.column :seller_property_profile_id,  :string, :limit => 36, :null => false, :references => :seller_property_profiles
          t.column :owner_name, :string
          t.column :is_seller_lead_owner, :boolean

          t.timestamps
        end
        puts "Setting primary key"
        execute "ALTER TABLE seller_property_owners ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SellerPropertyOwner.table_exists? rescue false
    if exists
      drop_table :seller_property_owners
    end
  end
end
