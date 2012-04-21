class AddColumnsToBuyerWebPages < ActiveRecord::Migration
  def self.up
    add_column :buyer_web_pages,:domain_permalink_text,:string, :default => nil
  end

  def self.down
    remove_column :buyer_web_pages,:domain_permalink_text
  end
end
