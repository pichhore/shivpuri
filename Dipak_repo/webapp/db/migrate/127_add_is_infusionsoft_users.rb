class AddIsInfusionsoftUsers < ActiveRecord::Migration
  def self.up
	add_column :users, :is_infusionsoft, :boolean, :default=>0
  end

  def self.down
	remobe_column :users, :is_infusionsoft
  end
end
