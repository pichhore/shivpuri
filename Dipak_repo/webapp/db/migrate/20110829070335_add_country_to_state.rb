class AddCountryToState < ActiveRecord::Migration
  def self.up
    add_column :states, :country, :string, :default => "us"
  end

  def self.down
    remove_column :states, :country
  end
end
