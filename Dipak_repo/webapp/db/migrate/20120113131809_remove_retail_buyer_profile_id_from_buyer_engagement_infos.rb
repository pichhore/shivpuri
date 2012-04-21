class RemoveRetailBuyerProfileIdFromBuyerEngagementInfos < ActiveRecord::Migration
  def self.up
   # remove_column :buyer_engagement_infos, :retail_buyer_profile_id
  end

  def self.down
   # add_column :buyer_engagement_infos, :retail_buyer_profile_id, :string
  end
end
