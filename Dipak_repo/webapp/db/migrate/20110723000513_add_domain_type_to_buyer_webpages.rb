class AddDomainTypeToBuyerWebpages < ActiveRecord::Migration
  def self.up
    add_column :buyer_web_pages, :domain_type, :string
  end

  def self.down
    remove_column :buyer_web_pages, :domain_type
  end
end
