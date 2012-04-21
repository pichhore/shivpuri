class AddZip27332ToZips < ActiveRecord::Migration
  def self.up
    county = County.find_by_name("Lee")
    zip = Zip.create(:zip => "27332", :state => "NC", :city => "SANFORD", :lat => 35.462654, :lng => -79.171158, :county_id=>county.id)
  end

  def self.down
  end
end
