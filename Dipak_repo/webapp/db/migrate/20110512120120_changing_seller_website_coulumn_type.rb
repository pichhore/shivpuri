class ChangingSellerWebsiteCoulumnType < ActiveRecord::Migration
  def self.up
    change_column :seller_websites, :home_page_main_text_1, :text
    change_column :seller_websites, :home_page_main_text_2, :text  
  end

  def self.down
    change_column :seller_websites, :home_page_main_text_1, :string
    change_column :seller_websites, :home_page_main_text_2, :string
  end
end
