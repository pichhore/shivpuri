class ChangeColumnInEmailAlertToUsers < ActiveRecord::Migration
  def self.up
    remove_column :email_alert_to_users, :email_alert_definition_id
    add_column :email_alert_to_users, :user_email_alert_definition_id, :string, :limit => 36, :null => false, :references => :user_email_alert_definitions
  end

  def self.down
  end
end