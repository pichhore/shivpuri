class UpdateTerritoryForZip27332 < ActiveRecord::Migration
  def self.up
   zip = Zip.find_by_zip("27332")
   territory = Territory.find_by_reim_name("Sandhills")
   zip.update_attribute(:territory_id, territory.id)
  end

  def self.down
  end
end
