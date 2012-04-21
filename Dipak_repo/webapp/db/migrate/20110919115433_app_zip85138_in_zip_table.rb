class AppZip85138InZipTable < ActiveRecord::Migration
  def self.up
    territory = Territory.find_by_reim_name("Southeastern_Maricopa_County")
    county = County.find_by_name("PINAL")
    zip = Zip.create(:zip => "85138", :state => "AZ", :city => "MARICOPA", :lat => 33.075263, :lng => -112.032976, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
