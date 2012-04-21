class AddSellerMagnetFieldsSellerSites < ActiveRecord::Migration
  def self.up
    add_column :seller_websites, :landing_page_headline, :text
    add_column :seller_websites, :results_page_copy, :text
    add_column :seller_websites, :thankyou_page_headline, :text
    add_column :seller_websites, :thankyou_page_copy, :text
    add_column :seller_websites, :seller_magnet, :boolean, :default => false
  end

  def self.down
    remove_column :seller_websites, :landing_page_headline
    remove_column :seller_websites, :results_page_copy
    remove_column :seller_websites, :thankyou_page_headline
    remove_column :seller_websites, :thankyou_page_copy
    remove_column :seller_websites, :seller_magnet
  end
end
