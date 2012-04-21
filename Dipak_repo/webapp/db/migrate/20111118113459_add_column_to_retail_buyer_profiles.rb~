class AddColumnToRetailBuyerProfiles < ActiveRecord::Migration
  def self.up
    add_column :retail_buyer_profiles, :is_archive, :boolean, :default => false
    add_column :retail_buyer_profiles, :delete_reason,  :string
    add_column :retail_buyer_profiles, :delete_comment, :text
     
    RetailBuyerProfile.reset_column_information
    RetailBuyerProfile.all.each { |f| f.update_attributes! :is_archive => false }
  end

  def self.down
    remove_column  :retail_buyer_profiles, :is_archive, :delete_reason, :delete_comment
  end
end
