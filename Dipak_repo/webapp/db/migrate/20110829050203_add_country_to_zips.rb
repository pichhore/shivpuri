class AddCountryToZips < ActiveRecord::Migration
  def self.up
    add_column :zips, :country, :string, :default => "us"
    change_column :zips, :zip, :string,  :limit => 7, :null => false
  end

  def self.down
#     remove_column :zips, :country
    change_column :zips, :zip, :string,  :limit => 5, :null => false
  end
end
