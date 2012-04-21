class AddWelcomeAlertExpiryColumnToAlertDefinitions < ActiveRecord::Migration
  def self.up
    add_column :alert_definitions, :welcome_alert_expiry, :datetime
  end

  def self.down
    remove_column :alert_definitions, :welcome_alert_expiry
  end
end
