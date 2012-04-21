class AddColumnsToSellerProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_profiles, :delete_reason, :string
    add_column :seller_profiles, :delete_comment, :text
  end

  def self.down
    remove_column :seller_profiles, :delete_reason
    remove_column :seller_profiles, :delete_comment
  end
end
