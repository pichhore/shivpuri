class AddDomainTypeToSellerWebsite < ActiveRecord::Migration
  def self.up
    add_column :seller_websites,:domain_type,:string
  end

  def self.down
    remove_column :seller_websites,:domain_type
  end
end
