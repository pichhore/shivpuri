class ChangeColumnInSellerProfile < ActiveRecord::Migration
  def self.up
    change_column :seller_profiles, :seller_website_id, :string, :limit => 36, :null => true
  end

  def self.down
    change_column :seller_profiles, :seller_website_id, :string, :limit => 36, :null => false
  end
end
