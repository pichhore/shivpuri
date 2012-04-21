class CreateSiteStats < ActiveRecord::Migration
  def self.up
    exists = SiteStat.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table site_stats..."
        create_table :site_stats, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :site_stat_type_id, :string, :limit => 36
          t.column :user_id, :string, :limit => 36, :references=>nil
          t.column :profile_id, :string, :limit => 36, :references=>nil
          t.column :value_num, :integer
          t.column :stats_date, :date, :null => false
          t.column :created_on, :date, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE site_stats ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SiteStat.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table site_stats..."
        drop_table :site_stats
      end
    end
  end
end
