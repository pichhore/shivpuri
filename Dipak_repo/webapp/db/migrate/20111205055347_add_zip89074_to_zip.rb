class AddZip89074ToZip < ActiveRecord::Migration
  def self.up
    territory = Territory.find_by_reim_name("Southern_Nevada")
    county = County.find_by_name("Clark")
    zip = Zip.create(:zip => "89074", :state => "NV", :city => "Henderson", :lat => 36.031252, :lng => -115.073868, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
