class UpdateZipInfoInZipTable < ActiveRecord::Migration

  def self.up
    zip = "78640"
    city = {"78640" => "KYLE"}
    latitude = {"78640" => 29.99008}
    longitude = {"78640" => -97.842228}
    zip_entry = Zip.find_by_zip(zip)
    zip_entry.update_attributes(:city => city[zip], :lat => latitude[zip], :lng => longitude[zip])
  end

  def self.down
  end

end
