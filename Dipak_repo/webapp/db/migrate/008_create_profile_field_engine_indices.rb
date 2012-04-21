class CreateProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    unless ProfileFieldEngineIndex.table_exists?
      create_table :profile_field_engine_indices, :id => false, :options => 'ENGINE=MyISAM' do |t|
        t.column :id, :string, :limit => 36, :null => false
        t.column :profile_id, :string, :limit => 36, :null => false

        t.column :is_owner, :boolean, :null => false
        t.column :zip_code, :string, :null => false
        t.column :property_type, :string, :null => false
        t.column :beds, :integer, :null => false
        t.column :baths, :integer, :null => false
        t.column :square_feet, :integer, :null => false
        t.column :square_feet_min, :integer, :null => false
        t.column :square_feet_max, :integer, :null => false
        t.column :price, :integer
        t.column :price_min, :integer
        t.column :price_max, :integer
        t.column :units, :integer, :null => false
        t.column :units_min, :integer, :null => false
        t.column :units_max, :integer, :null => false
        t.column :acres, :integer, :null => false
        t.column :acres_min, :integer, :null => false
        t.column :acres_max, :integer, :null => false
        t.column :profile_created_at, :datetime
      end

      execute "ALTER TABLE profile_field_engine_indices ADD PRIMARY KEY (id)"
  
      add_index :profile_field_engine_indices, :profile_id
      add_index :profile_field_engine_indices, :zip_code
    end
  end
  
  def self.down
    if ProfileFieldEngineIndex.table_exists?
      drop_table :profile_field_engine_indices
    end
  end
end
