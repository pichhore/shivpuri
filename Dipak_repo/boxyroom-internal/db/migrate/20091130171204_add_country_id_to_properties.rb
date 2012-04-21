class AddCountryIdToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :country_id, :integer
  end

  def self.down
    remove_column :properties, :country_id
  end
end
