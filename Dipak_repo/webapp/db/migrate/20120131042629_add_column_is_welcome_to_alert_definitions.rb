class AddColumnIsWelcomeToAlertDefinitions < ActiveRecord::Migration
  def self.up
    add_column :alert_definitions, :is_welcome_alert, :boolean, :default => false
    AlertDefinition.reset_column_information
    AlertDefinition.all.each do |alert|
      alert.is_welcome_alert = false
      alert.save!
      #alert.send(:update_without_callbacks)
    end
  end

  def self.down
    remove_column :alert_definitions, :is_welcome_alert
  end
end
