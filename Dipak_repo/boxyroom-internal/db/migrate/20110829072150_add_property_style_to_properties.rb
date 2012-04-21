class AddPropertyStyleToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :property_style, :string
  end

  def self.down
    remove_column :properties, :property_style
  end
end
