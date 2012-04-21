class CreateEmailAlertToUsers < ActiveRecord::Migration
  def self.up
    create_table :email_alert_to_users do |t|
      t.datetime :event_time
      t.string :user_id, :limit => 36, :null => false, :references => :users
      t.string :email_alert_definition_id, :limit => 36, :null => false, :references => :email_alert_definitions
      t.timestamps
    end
  end

  def self.down
    drop_table :email_alert_to_users
  end
end
