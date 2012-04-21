class ChangeColumnRetailBuyerProfileIdBuyerEngagementInfos < ActiveRecord::Migration
  def self.up
    change_column :buyer_engagement_infos, :retail_buyer_profile_id, :string, :null => true
  end

  def self.down
    change_column :buyer_engagement_infos, :retail_buyer_profile_id, :string, :null => false
  end
end
