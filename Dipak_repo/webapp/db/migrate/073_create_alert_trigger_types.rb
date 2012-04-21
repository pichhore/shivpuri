class CreateAlertTriggerTypes < ActiveRecord::Migration
  def self.up
		exists = AlertTriggerType.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table alert_trigger_types..."
				create_table :alert_trigger_types, :id => false do |t|
					t.string :id, :limit => 36, :null => false
					t.string :name, :null => false
          t.string :description, :null => false
					t.string :method_name, :null => false
					t.string :parameter_description
					t.timestamps
				end
				puts "Setting primary key"
				execute "ALTER TABLE alert_trigger_types ADD PRIMARY KEY (id)"
        
        AlertTriggerType.create!({:name=>'Always', :method_name=>'always', :parameter_description=>'No extra parameters',
                                  :description=>'Alerts defined with this type will be created for all users with no restrictions.  This can be used for a global message that needs to go out to everyone immediately.', 
                                 })
        AlertTriggerType.create!({:name=>'Never', :method_name=>'never', :parameter_description=>'No extra parameters',
                                  :description=>'For testing only - this will never trigger an alert.'
                                 })
        AlertTriggerType.create!({:name=>'Event-based', :method_name=>'on_event', :parameter_description=>'A date field accessible from the user, possible values are: created_at, updated_at, activated_at, last_login_at, previous_login_at',
                                  :description=>'Creates alerts based on an event such as account activation.  Can be limited to a window of time after the event.'
                                 })
		 end
    end
  end

  def self.down
    exists = AlertTriggerType.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table alert_trigger_types..."
				drop_table :alert_trigger_types
      end
    end
  end
end
