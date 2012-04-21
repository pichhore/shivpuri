class AddColumnEmailTypeToEmailAlertDefinitions < ActiveRecord::Migration
  def self.up
    add_column :email_alert_definitions, :email_type, :string, :default => "property_profile"
  end

  def self.down
    remove_column :email_alert_definitions, :email_type
  end
end
