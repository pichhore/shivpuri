class AddEmbedFieldsForInvestorWebsite < ActiveRecord::Migration
  def self.up
    add_column :investor_websites, :home_page_embed, :text
    add_column :investor_websites, :about_embed, :text
    add_column :investor_websites, :philosophy_embed, :text
    add_column :investor_websites, :why_invest_embed, :text
  end

  def self.down
    remove_column :investor_websites, :home_page_embed
    remove_column :investor_websites, :about_embed
    remove_column :investor_websites, :philosophy_embed
    remove_column :investor_websites, :why_invest_embed
  end
end
