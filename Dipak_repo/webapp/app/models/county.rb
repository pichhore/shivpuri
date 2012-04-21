class County < ActiveRecord::Base
COUNTRY_NAME = [ 
    [ "USA", "US" ],
    [ "Canada", "CA" ]
  ]

  def self.get_counties_for_state(state_id)
    self.find(:all, :joins => "INNER JOIN territories on territory_counties.territory_id = territories.id", :conditions=>["counties.id = territory_counties.county_id && territories.state_id = ?", state_id], :order=>"counties.name asc", :select => "distinct counties.*", :from => "counties, territory_counties")
  end
end
