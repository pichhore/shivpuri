class UpdateCityForZip93907 < ActiveRecord::Migration
  def self.up
    zip = "93907"
    city = {"93907" => "SALINAS"}
    zip_entry = Zip.find_by_zip(zip)
    zip_entry.update_attributes(:city => city[zip])
  end

  def self.down
  end

end
