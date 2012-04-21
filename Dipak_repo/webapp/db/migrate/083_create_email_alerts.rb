class CreateEmailAlerts < ActiveRecord::Migration
  def self.up
    exists = EmailAlert.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table email_alerts..."
        create_table :email_alerts, :id =>false do |t|
          t.string :id, :limit => 36, :null => false
          t.datetime :event_time          
          t.string :user_id, :limit => 36, :null => false, :references => nil
          t.string :email_alert_definition_id, :limit => 36, :null => false, :references => nil
          t.timestamps
        end

        puts "Setting primary key"
        execute "ALTER TABLE email_alerts ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'user_id'"
        add_index :email_alerts, :user_id

        puts "Adding indexed column 'email_alert_definition_id'"
        add_index :email_alerts, :email_alert_definition_id
      end
    end
  end

  def self.down
    exists = EmailAlert.table_exists? rescue false
    if exists
      transaction do
        drop_table :email_alerts
      end
    end
  end
end
