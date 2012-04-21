class CreateBuyerEngagementInfo < ActiveRecord::Migration

  def self.up
    exists = BuyerEngagementInfo.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table buyer_engagement_infos..."
        create_table "buyer_engagement_infos" do |t|
          # t.column :id,                        :string, :limit => 36, :null => false
          t.column :retail_buyer_profile_id,:string, :limit => 36, :null => false
          t.column :note_type,                 :string
          t.column :subject,                   :text
          t.column :description,               :text
          t.timestamps
        end
       
      end
    end
  end

  def self.down
    exists = BuyerEngagementInfo.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table buyer_engagement_infos..."
        drop_table :buyer_engagement_infos
      end
    end
  end
end
