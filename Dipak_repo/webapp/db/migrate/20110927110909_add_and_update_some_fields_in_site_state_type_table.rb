class AddAndUpdateSomeFieldsInSiteStateTypeTable < ActiveRecord::Migration
  def self.up
    execute "UPDATE site_stat_types SET name='Accounts Created to Date' WHERE id='total_active_accounts'"
    execute "UPDATE site_stat_types SET name='Active Properties (Private)' WHERE id='total_active_owners_private'"
    execute "UPDATE site_stat_types SET name='Active Properties (Public)' WHERE id='total_active_owners_public'"
    execute "UPDATE site_stat_types SET name='Total Active Properties' WHERE id='total_active_owner_profiles'"
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('pro_subscription_users','Total PRO Subscribers',now())"
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('plus_subscription_users','Total PLUS Subscribers',now())"
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('free_subscription_users','Total FREE Subscribers',now())"
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('failed_payment_users','Total Failed Payment Subscribers',now())"
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('seller_lead_in_reim','Total Seller Leads (Active)',now())"
  end

  def self.down
  end
end
