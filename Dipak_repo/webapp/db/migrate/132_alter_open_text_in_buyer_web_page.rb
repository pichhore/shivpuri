class AlterOpenTextInBuyerWebPage < ActiveRecord::Migration
  def self.up
    change_column :buyer_web_pages,:opening_text,:string,:limit=>400
  end

  def self.down
    change_column :buyer_web_pages,:opening_text,:string,:limit=>255
  end
end
