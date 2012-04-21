class RemovePostalAddNewFieldsProperty < ActiveRecord::Migration
  def self.up
    remove_column :properties, :postal_code
    add_column  :properties, :sublet, :boolean
    add_column  :properties, :pets_allowed, :boolean
    add_column  :properties, :occupancy, :integer
    add_column  :properties, :short_notice, :boolean
  end

  def self.down
    add_column  :properties, :postal_code, :string
    remove_column :properties, :sublet
    remove_column :properties, :pets_allowed
    remove_column :properties, :occupancy
    remove_column :properties, :short_notice
  end
end
