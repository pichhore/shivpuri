class AddZip65673ToZips < ActiveRecord::Migration
  def self.up
    territory = Territory.find_by_reim_name("Southwest_Missouri")
    county = County.find_by_name("Taney")
    zip = Zip.create(:zip => "65673", :state => "MO", :city => "HOLLISTER", :lat => 36.6239, :lng => -93.2085, :territory_id=>territory.id, :county_id=>county.id)
  end

  def self.down
  end
end
