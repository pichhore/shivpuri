class AddHouseRulesToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :house_rules, :text
  end

  def self.down
    remove_column :properties, :house_rules
  end
end
