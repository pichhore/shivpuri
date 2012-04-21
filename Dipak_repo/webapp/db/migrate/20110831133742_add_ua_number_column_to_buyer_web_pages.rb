class AddUaNumberColumnToBuyerWebPages < ActiveRecord::Migration
  def self.up
    add_column :buyer_web_pages, :ua_number, :string
  end

  def self.down
    remove_column :buyer_web_pages, :ua_number
  end
end
