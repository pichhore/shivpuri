class AddCssBuyerWebApge < ActiveRecord::Migration
  def self.up
    add_column :buyer_web_pages, :dynamic_css, :string
  end

  def self.down
    remove_column :buyer_web_pages, :dynamic_css
  end
end
