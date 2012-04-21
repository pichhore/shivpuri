class AddSubscriptionColumnToRetailBuyerProfile < ActiveRecord::Migration
  def self.up
    add_column :retail_buyer_profiles, :welcome_email_subscription,:boolean,:default=>true
    add_column :retail_buyer_profiles, :daily_email_subscription,:boolean,:default=>true
    add_column :retail_buyer_profiles, :weekly_email_subscription,:boolean,:default=>true
    add_column :retail_buyer_profiles, :trust_responder_subscription,:boolean,:default=>true
  end

  def self.down
    remove_column :retail_buyer_profiles, :welcome_email_subscription
    remove_column :retail_buyer_profiles, :daily_email_subscription
    remove_column :retail_buyer_profiles, :weekly_email_subscription
    remove_column :retail_buyer_profiles, :trust_responder_subscription
  end
end
