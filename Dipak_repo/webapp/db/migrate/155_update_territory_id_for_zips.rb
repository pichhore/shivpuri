class UpdateTerritoryIdForZips < ActiveRecord::Migration
  def self.up
    if table_exists?("zips")
      execute("update zips set territory_id=125 where zip in (63033,63034,63031);")
    end
  end

  def self.down
    if table_exists?("zips")
      execute("update zips set territory_id=119 where zip in (63033,63034,63031);")
    end
  end

  def self.table_exists?(name)
    ActiveRecord::Base.connection.tables.include?(name)
  end
  
end
