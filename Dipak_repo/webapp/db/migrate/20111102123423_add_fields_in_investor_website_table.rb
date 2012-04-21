class AddFieldsInInvestorWebsiteTable < ActiveRecord::Migration
  def self.up
    add_column :investor_websites, :display_our_philosophy_page, :boolean
    add_column :investor_websites, :display_why_invest_with_us_page, :boolean
    add_column :investor_websites, :our_philosophy_page_text, :text
    add_column :investor_websites, :why_invest_with_us_page_text, :text
  end

  def self.down
    remove_column :investor_websites, :display_our_philosophy_page
    remove_column :investor_websites, :display_why_invest_with_us_page
    remove_column :investor_websites, :our_philosophy_page_text
    remove_column :investor_websites, :why_invest_with_us_page_text
  end
end
