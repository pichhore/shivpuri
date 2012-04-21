class AddSquareMetresOrFeetToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :unit, :string
  end

  def self.down
    remove_column :properties, :unit
  end
end
