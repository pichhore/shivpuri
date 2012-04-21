class UpdateCanadaToTerritories < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO territories VALUES ('CAAB','Alberta','1020','alberta','ca'),('CAMB','Manitoba','1021','manitoba','ca'),('CANL','Newfoundland and Labrador','1022','newfoundland_and_labrador','ca'),('CANS','Nova Scotia','1023','nova_scotia','ca'),('CAON','Ontario','1024','ontario','ca'),('CAQC','Quebec','1025','quebec','ca'),('CAYT','Yukon','1026','yukon','ca'),('CABC','British Columbia','1027','british_columbia','ca'),('CANB','New Brunswick','1028','new_brunswick','ca'),('CANT','Northwest Territories','1029','northwest_territories','ca'),('CANU','Nunavut','1030','nunavut','ca'),('CAPE','Prince Edward Island','1031','prince_edward_island','ca'),('CASK','Saskatchewan','1032','saskatchewan','ca');"
  end

  def self.down
    territories = Territory.find(:all, :conditions => ["country = ?", "ca"])
    territories.each do |territory|
      territory.destroy
    end
  end
end
