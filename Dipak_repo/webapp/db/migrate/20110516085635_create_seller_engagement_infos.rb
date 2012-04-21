class CreateSellerEngagementInfos < ActiveRecord::Migration

  def self.up
    exists = SellerEngagementInfo.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table seller_engagement_infos..."
        create_table "seller_engagement_infos", :id => false do |t|
          t.column :id,                        :string, :limit => 36, :null => false
          t.column :seller_property_profile_id,:string, :limit => 36, :null => false, :references => :seller_property_profiles
          t.column :note_type,                 :string
          t.column :subject,                   :text
          t.column :description,               :text
          t.timestamps
        end
        puts "Setting primary key"
        execute "ALTER TABLE seller_engagement_infos ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SellerEngagementInfo.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table seller_engagement_infos..."
        drop_table :seller_engagement_infos
      end
    end
  end
end