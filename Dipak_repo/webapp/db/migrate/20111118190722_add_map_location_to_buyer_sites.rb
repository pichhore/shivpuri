class AddMapLocationToBuyerSites < ActiveRecord::Migration
  def self.up
    add_column :buyer_web_pages, :map_location, :string
  end

  def self.down
    remove_column :buyer_web_pages, :map_location
  end
end
