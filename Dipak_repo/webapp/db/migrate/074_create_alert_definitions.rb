class CreateAlertDefinitions < ActiveRecord::Migration
  def self.up
    exists = AlertDefinition.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table alert_definition..."
				create_table :alert_definitions, :id => false do |t|
          t.string :id, :limit => 36, :null => false
					t.string :title, :null => false
					t.string :message, :limit => 500, :null => false
					t.text :details, :null => false
					t.integer :trigger_delay_days
					t.integer :trigger_cutoff_days
					t.integer :auto_expire_days   # not used yet, may be used to auto-dismiss old alerts
					t.string :alert_trigger_type_id, :limit => 36, :null => false, :references => nil
          t.string :trigger_parameter_value
          t.boolean :disabled
					t.timestamps
          t.column :deleted_at, :datetime # acts_as_paranoid
				end

        puts "Setting primary key"
        execute "ALTER TABLE alert_definitions ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'alert_trigger_type_id'"
        add_index :alert_definitions, :alert_trigger_type_id
			end
    end
  end

  def self.down
    exists = AlertDefinition.table_exists? rescue false
    if exists
      transaction do
				drop_table :alert_definitions
			end
		end
  end
end

