class AddZipEntryForCode32348 < ActiveRecord::Migration
  def self.up
    territory = Territory.find_by_reim_name("East_Panhandle")
    county = County.find_by_name("TAYLOR")
    zip = Zip.create(:zip => "32348", :state => "FL", :city => "PERRY", :lat => 29.899208, :lng => -83.55331, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
