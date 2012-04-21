class AddCountryToTerritories < ActiveRecord::Migration
  def self.up
     add_column :territories, :country, :string, :default => "us"
  end

  def self.down
      remove_column :territories, :country
  end
end
