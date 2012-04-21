class AddStateOnTerritory < ActiveRecord::Migration
  def self.up
    add_column :territories, :state_id, :string
    add_column :territories, :reim_name, :string
  end

  def self.down
    remove_column :territories, :state_id
    remove_column :territories, :reim_name
  end
end
