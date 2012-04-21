class AddLayoutColumnInInvestorWebsiteTable < ActiveRecord::Migration
  def self.up
    add_column :investor_websites, :layout, :string
  end

  def self.down
    remove_column :investor_websites, :layout
  end
end
