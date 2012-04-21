class AddFieldUserClassInAlertDefinitions < ActiveRecord::Migration
  def self.up
    add_column :alert_definitions, :user_class_id, :integer, :default => nil
  end

  def self.down
    remove_column :alert_definitions, :user_class_id
  end
end
