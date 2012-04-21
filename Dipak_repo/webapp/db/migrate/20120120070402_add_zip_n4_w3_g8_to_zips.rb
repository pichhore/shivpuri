class AddZipN4W3G8ToZips < ActiveRecord::Migration
  def self.up
     zip = Zip.create(:zip => "N4W 3G8", :state => "ON", :city => "Listowel", :lat => 43.720476, :lng => -80.85751, :territory_id=>"CAON", :country => "ca")
  end

  def self.down
  end
end
