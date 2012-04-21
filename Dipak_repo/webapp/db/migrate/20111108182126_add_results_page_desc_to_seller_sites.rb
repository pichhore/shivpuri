class AddResultsPageDescToSellerSites < ActiveRecord::Migration
  def self.up
    add_column :seller_websites, :results_page_content, :text
  end

  def self.down
    remove_column :seller_websites, :results_page_content
  end
end
