class DefaultVideoSellerWebsite < ActiveRecord::Migration
  def self.up
    add_column :seller_websites, :default_video, :boolean
  end

  def self.down
    remove_column :seller_websites, :default_video
  end
end