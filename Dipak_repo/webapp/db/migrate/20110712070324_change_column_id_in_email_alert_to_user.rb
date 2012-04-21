class ChangeColumnIdInEmailAlertToUser < ActiveRecord::Migration
  def self.up
    change_column :email_alert_to_users, :id, :string, :limit => 36, :null => false
  end

  def self.down
  end
end
