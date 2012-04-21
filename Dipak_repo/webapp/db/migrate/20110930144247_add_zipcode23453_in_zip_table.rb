class AddZipcode23453InZipTable < ActiveRecord::Migration
  def self.up
    territory = Territory.find_by_reim_name("Tidewater")
    county = County.find_by_name("VIRGINIA BEACH CITY")
    zip = Zip.create(:zip => "23453", :state => "VA", :city => "VIRGINIA BEACH", :lat => 36.782218, :lng => -76.077854, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
