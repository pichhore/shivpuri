class AddUaNumberColumnToSellerWebsites < ActiveRecord::Migration
  def self.up
    add_column :seller_websites, :ua_number, :string
  end

  def self.down
    remove_column :seller_websites, :ua_number
  end
end
