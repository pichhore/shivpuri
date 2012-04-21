class UpdateCanadaTerritoriesToZips < ActiveRecord::Migration
  def self.up
    zips = Zip.find(:all, :conditions => ["country=?","ca"])
    zips.each do |zip|
      zip.update_attribute(:territory_id,"CA#{zip.state}")
    end 
  end

  def self.down
  end
end
