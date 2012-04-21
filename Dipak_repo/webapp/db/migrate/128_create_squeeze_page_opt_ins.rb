class CreateSqueezePageOptIns < ActiveRecord::Migration
  def self.up
    exists = SqueezePageOptIn.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table SqueezePageOptIn..."
        create_table "squeeze_page_opt_ins", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_territory_id, :string, :limit => 36
            t.column :retail_buyer_first_name, :string
            t.column :retail_buyer_email, :string
        end

        puts "Setting primary key"
        execute "ALTER TABLE squeeze_page_opt_ins ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :squeeze_page_opt_ins
  end
end
