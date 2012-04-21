class CreateTerritoryCounties < ActiveRecord::Migration
  def self.up
    exists = TerritoryCounty.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table TerritoryCounty... county_d , territory_id"
        create_table "territory_counties", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :county_id, :string, :limit => 36
            t.column :territory_id, :string, :limit => 36
        end

        puts "Setting primary key"
        execute "ALTER TABLE territory_counties ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :territory_counties
  end
end
