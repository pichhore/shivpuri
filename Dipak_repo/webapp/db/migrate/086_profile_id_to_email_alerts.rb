class ProfileIdToEmailAlerts < ActiveRecord::Migration
  def self.up
    add_column :email_alerts, :profile, :string
  end

  def self.down
    drop_column :email_alerts, :profile, :string
  end
end
