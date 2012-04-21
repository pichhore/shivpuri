class AddZip32162ToZips < ActiveRecord::Migration
  def self.up
     territory = Territory.find_by_reim_name("Orlando_Region")
    county = County.find_by_name("Sumter")
    zip = Zip.create(:zip => "32162", :state => "FL", :city => "LADY LAKE", :lat => 28.917856, :lng => -82.001442, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
