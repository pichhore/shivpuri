class UpdateCountyWithCorrectTerritory < ActiveRecord::Migration
  def self.up
    execute "UPDATE territory_counties SET territory_id=221 WHERE id=3249"
  end

  def self.down
    execute "UPDATE territory_counties SET territory_id=204 WHERE id=3249"
  end
end
