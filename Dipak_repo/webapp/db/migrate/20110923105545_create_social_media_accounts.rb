class CreateSocialMediaAccounts < ActiveRecord::Migration
  def self.up
    create_table :social_media_accounts do |t|
      t.string :url
      t.string :user_id, :limit => 36
      t.integer :url_type_id, :references => nil
      t.integer :site_type_id, :references => nil

      t.timestamps
    end
  end

  def self.down
    drop_table :social_media_accounts
  end
end
