class AddColumnsInUserEmailAlertDefinition < ActiveRecord::Migration
  def self.up
    add_column :user_email_alert_definitions, :product_ids, :string
  end

  def self.down
    remove_column :user_email_alert_definitions, :product_ids
  end
end
