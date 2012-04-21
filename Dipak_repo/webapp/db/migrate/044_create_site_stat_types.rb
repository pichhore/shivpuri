class CreateSiteStatTypes < ActiveRecord::Migration
  def self.up
    exists = SiteStatType.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table site_stat_types..."
        create_table :site_stat_types, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :name, :string, :null=> false
          t.column :created_at, :datetime, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE site_stat_types ADD PRIMARY KEY (id)"

        puts "Installing default site stat types"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_active_accounts','Total Active User Accounts',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_active_buyer_profiles','Total Active Buyer Profiles',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_active_owner_profiles','Total Active Owner Profiles',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_active_owners_public','Total Active Owners (Public)',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_active_owners_private','Total Active Owners (Private)',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_sent_messages','Total Sent Messages',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_logins_daily','Total Daily Logins',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_digest_daily','Total Daily Digest Subscribers',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_digest_weekly','Total Weekly Digest Subscribers',now())"
        execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_digest_monthly','Total Monthly Digest Subscribers',now())"
      end
    end
  end

  def self.down
    exists = SiteStatType.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table site_stat_types..."
        drop_table :site_stat_types
      end
    end
  end
end
