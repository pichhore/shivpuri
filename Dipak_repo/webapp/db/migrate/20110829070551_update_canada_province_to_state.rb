class UpdateCanadaProvinceToState < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO `states` VALUES ('1020','Alberta','AB','ca'),('1021','Manitoba','MB','ca'),('1022','Newfoundland and Labrador','NL','ca'),('1023','Nova Scotia','NS','ca'),('1024','Ontario','ON','ca'),('1025','Quebec','QC','ca'),('1026','Yukon','YT','ca'),('1027','British Columbia','BC','ca'),('1028','New Brunswick','NB','ca'),('1029','Northwest Territories','NT','ca'),('1030','Nunavut','NU','ca'),('1031','Prince Edward Island','PE','ca'),('1032','Saskatchewan','SK','ca');"
  end

  def self.down
    states = State.find(:all, :conditions => ["country = ?", "ca"])
    states.each do |state|
      state.destroy
    end
  end
end
