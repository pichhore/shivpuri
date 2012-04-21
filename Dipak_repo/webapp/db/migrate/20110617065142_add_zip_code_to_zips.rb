class AddZipCodeToZips < ActiveRecord::Migration
  def self.up
    Zip.create(:zip => "33559", :state => "FL", :city => "LUTZ", :lat => 28.1665, :lng => -82.4091, :county_id => "781", :territory_id => "58")
    Zip.create(:zip => "33558", :state => "FL", :city => "LUTZ", :lat => 28.1571, :lng => -82.5217, :county_id => "781", :territory_id => "58")
    Zip.create(:zip => "33548", :state => "FL", :city => "LUTZ", :lat => 28.1452, :lng => -82.4791, :county_id => "781", :territory_id => "58")

  end

  def self.down
    zip_array = ["33559", "33558", "33548"]
    zips  = Zip.find(:all, :conditions => ["zip in (?)",zip_array])
    zips.each do |zip| zip.destroy end if !zips.empty?
  end
end
