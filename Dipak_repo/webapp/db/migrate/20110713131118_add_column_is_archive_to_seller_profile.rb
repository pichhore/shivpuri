class AddColumnIsArchiveToSellerProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_profiles, :is_archive, :boolean, :default=>false
  end

  def self.down
    remove_column :seller_profiles, :is_archive
  end
end
