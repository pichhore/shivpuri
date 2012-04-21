class AddCountryToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles,:country,:string,:default=> "US"
  end

  def self.down
    remove_column :profiles,:country
  end
end
