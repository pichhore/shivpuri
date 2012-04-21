class CreateRetailProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    exists = RetailProfileFieldEngineIndex.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table retail_profile_field_engine_indices..."
        create_table "retail_profile_field_engine_indices", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :retail_buyer_profile_id, :string, :limit => 36
            t.column :zip_code, :string
            t.column :property_type, :string
            t.column :beds, :integer
            t.column :baths, :integer
            t.column :square_feet_min, :integer
            t.column :square_feet_max, :integer
            t.column :units_min, :integer
            t.column :units_max, :integer
            t.column :acres_min, :integer
            t.column :acres_max, :integer
            t.column :max_mon_pay, :integer
            t.column :max_dow_pay, :integer
            t.column :description, :string
            t.column :county, :string
            t.column :updated_at, :datetime
            t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE retail_profile_field_engine_indices ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :retail_profile_field_engine_indices
  end
end
