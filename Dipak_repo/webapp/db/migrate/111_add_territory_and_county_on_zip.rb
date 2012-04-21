class AddTerritoryAndCountyOnZip < ActiveRecord::Migration
  def self.up
    add_column :zips, :county_id, :string
    add_column :zips, :territory_id, :string
  end

  def self.down
    remove_column :zips, :county_id
    remove_column :zips, :territory_id
  end
end
