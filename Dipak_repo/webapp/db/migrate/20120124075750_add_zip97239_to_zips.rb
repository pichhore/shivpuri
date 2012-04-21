class AddZip97239ToZips < ActiveRecord::Migration
  def self.up
    territory = Territory.find_by_reim_name("Portland_Area")
    county = County.find_by_name("Multnomah")
    zip = Zip.create(:zip => "97239", :state => "OR", :city => "PORTLAND", :lat => 45.499, :lng => -122.688, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
