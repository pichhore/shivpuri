class UpdatePermalinkTerritory < ActiveRecord::Migration
  def self.up
    territories = Territory.find(:all)
    if territories.size > 0
      execute 'update territories set reim_name = territory_name;'
      execute 'update territories set reim_name =  SUBSTRING( reim_name , 1 , IF( INSTR(reim_name , "(") > 0 , INSTR(reim_name , "(")  , 100000 )  ) ;'
      execute 'update territories set reim_name = REPLACE(reim_name, "(","") ;'
      execute 'update territories set reim_name = TRIM(reim_name) ;'
      execute 'update territories set reim_name = REPLACE(reim_name, " ","_") ;'
      execute 'update territories set reim_name = REPLACE(reim_name, ",","") ;'
    end
  end

  def self.down
  end
end
