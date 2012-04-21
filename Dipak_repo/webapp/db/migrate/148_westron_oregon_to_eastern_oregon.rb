class WestronOregonToEasternOregon < ActiveRecord::Migration
  def self.up
      execute "UPDATE territories SET territory_name='Eastern Oregon (Klamath Falls/Bend/Baker City)', reim_name='Eastern_Oregon' WHERE id='185' and reim_name='Western_Oregon' "
  end

  def self.down
    execute "UPDATE territories SET territory_name='Western Oregon (Klamath Falls/Bend/Baker City)', reim_name='Western_Oregon' WHERE id='185' and reim_name='Eastern_Oregon'"
  end
end
