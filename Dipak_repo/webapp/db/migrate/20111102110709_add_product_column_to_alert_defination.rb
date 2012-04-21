class AddProductColumnToAlertDefination < ActiveRecord::Migration
  def self.up
   add_column :alert_definitions, :amps,          :boolean
   add_column :alert_definitions, :amps_gold,     :boolean
   add_column :alert_definitions, :top1,          :boolean
   add_column :alert_definitions, :re_volution,   :boolean
   add_column :alert_definitions, :rei_mkt_dept,  :boolean
  end

  def self.down
   add_column :alert_definitions, :amps
   add_column :alert_definitions, :amps_gold
   add_column :alert_definitions, :top1
   add_column :alert_definitions, :re_volution
   add_column :alert_definitions, :rei_mkt_dept
  end
end
