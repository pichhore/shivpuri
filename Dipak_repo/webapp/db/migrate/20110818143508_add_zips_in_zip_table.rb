class AddZipsInZipTable < ActiveRecord::Migration
  def self.up
    zips = ["84096", "76018", "23608", "23692"]
    states = {"84096" => "UT", "76018" => "TX", "23608" => "VA", "23692" => "VA"}
    cities = {"84096" => "HERRIMAN", "76018" => "ARLINGTON", "23608" => "NEWPORT NEWS", "23692" => "YORKTOWN"}
    latitude = {"84096" => 40.489182, "76018" => 32.660994, "23608" => 37.154698, "23692" => 37.178494}
    longitude = {"84096" => -112.050722, "76018"=> -97.085882, "23608" => -76.545796, "23692" => -76.470709}
    zips.each do |zip|
      zip_entry = Zip.find_by_zip(zip)
      if zip_entry.blank?
        zip_entry = Zip.create(:zip => zip, :state => states[zip], :city => cities[zip], :lat => latitude[zip], :lng => longitude[zip])
      else
        zip_entry.update_attributes(:state => states[zip], :city => cities[zip], :lat => latitude[zip], :lng => longitude[zip])
      end
    end
  end

  def self.down
  end
end
