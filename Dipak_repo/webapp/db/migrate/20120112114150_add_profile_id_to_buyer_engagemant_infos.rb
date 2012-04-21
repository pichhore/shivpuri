class AddProfileIdToBuyerEngagemantInfos < ActiveRecord::Migration
  def self.up
    add_column :buyer_engagement_infos, :profile_id, :string
  end

  def self.down
    remove_column :buyer_engagement_infos, :profile_id
  end
end
