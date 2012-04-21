class AddColumnToSellerEngagementInfo < ActiveRecord::Migration
  def self.up
    add_column :seller_engagement_infos, :scratch_pad_tag, :string
  end

  def self.down
    remove_column :seller_engagement_infos, :scratch_pad_tag
  end
end
