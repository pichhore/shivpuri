class Territory < ActiveRecord::Base
  uses_guid
  has_many :zips
  has_many :users, :through=>:user_territories
  has_many :user_territories
  has_many :feeds, :dependent => :destroy
  def self.get_territories_for_county_and_state(county_id, state_id)
    self.find(:all, :joins => "inner join territory_counties on territory_counties.territory_id = territories.id", :conditions => ["territory_counties.county_id = ? && territories.state_id = ? ", county_id, state_id])
  end

  def self.get_territory_for_zip(zip)
    Territory.find(zip.territory_id)
  end
end
