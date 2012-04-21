class UpdateTerritory < ActiveRecord::Migration
  def self.up
    execute "UPDATE territories SET territory_name='Southeast Indiana(Lawrenceburg/New Albany)', reim_name='Southeast_Indiana' WHERE id='86'"
  end
  
  def self.down
    execute "UPDATE territories SET territory_name='Southeast Illinois(Lawrenceburg/New Albany)', reim_name='Southeast_Illinois' WHERE id='86'"    
  end
end
