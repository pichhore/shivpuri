class CreateActivityLogs < ActiveRecord::Migration
  def self.up
    exists = ActivityLog.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table activity_logs..."
        create_table :activity_logs, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :activity_category_id, :string
          t.column :user_id, :string, :limit => 36, :references=>nil
          t.column :profile_id, :string, :limit => 36, :references=>nil
          t.column :description, :string
          t.column :session_id, :string, :references => nil
          t.column :ip_address, :string
          t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE activity_logs ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ActivityCategory.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table activity_logs..."
        drop_table :activity_logs
      end
    end
  end
end
