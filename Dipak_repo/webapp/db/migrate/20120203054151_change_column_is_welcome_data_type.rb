class ChangeColumnIsWelcomeDataType < ActiveRecord::Migration
  def self.up
     change_column :alert_definitions, :welcome_alert_expiry, :integer
  end

  def self.down
    change_column :alert_definitions, :welcome_alert_expiry, :datetime
  end
end
