class CreateUserEmailAlertDefinitions < ActiveRecord::Migration
  def self.up
    exists = UserEmailAlertDefinition.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table user email_alert_definition..."
        create_table :user_email_alert_definitions, :id => false do |t|
          t.string :id, :limit => 36, :null => false
          t.string :title, :null => false
          t.boolean :disabled
          t.string :trigger_parameter_value
          t.integer :trigger_delay_days
          t.string :email_subject, :limit => 500, :null => false
          t.text :message_body, :null => false
          t.string :email_type, :null => false
          t.timestamps
        end

        puts "Setting primary key"
        execute "ALTER TABLE user_email_alert_definitions ADD PRIMARY KEY (id)"

#         puts "Adding indexed column 'alert_trigger_type_id'"
#         add_index :user_email_alert_definitions, :alert_trigger_type_id
      end
    end
  end

  def self.down
    exists = UserEmailAlertDefinition.table_exists? rescue false
    if exists
      transaction do
        drop_table :user_email_alert_definitions
      end
    end
  end
end
