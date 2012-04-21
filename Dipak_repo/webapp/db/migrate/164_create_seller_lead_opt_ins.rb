class CreateSellerLeadOptIns < ActiveRecord::Migration
  def self.up
    exists = SellerLeadOptIn.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table seller_lead_opt_ins..."
         create_table :seller_lead_opt_ins, :id => false do |t|
            t.column :id,                        :string, :limit => 36, :null => false
            t.column :seller_website_id,         :string, :limit => 36, :null => false, :references => :seller_websites
            t.column :seller_first_name,         :string
            t.column :seller_email,              :string
            t.timestamps
          end
        puts "Setting primary key"
        execute "ALTER TABLE seller_lead_opt_ins ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SellerLeadOptIn.table_exists? rescue false
    if exists
      drop_table :seller_lead_opt_ins
    end
  end
end
