class AddMetaTagColumntoSellerWebsite < ActiveRecord::Migration
  def self.up
    add_column :seller_websites,:meta_title,:string
    add_column :seller_websites,:meta_description,:string
  end

  def self.down
    remove_column :seller_websites,:meta_title
    remove_column :seller_websites,:meta_description
  end
end
