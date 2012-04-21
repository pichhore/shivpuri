class CreateAlerts < ActiveRecord::Migration
  def self.up
    exists = Alert.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table alerts..."
				create_table :alerts, :id =>false do |t|
          t.string :id, :limit => 36, :null => false
					t.datetime :event_time
					t.boolean :dismissed, :null => false
          t.string :user_id, :limit => 36, :null => false, :references => nil
          t.string :alert_definition_id, :limit => 36, :null => false, :references => nil
					t.timestamps
				end

        puts "Setting primary key"
        execute "ALTER TABLE alerts ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'user_id'"
        add_index :alerts, :user_id

        puts "Adding indexed column 'alert_definition_id'"
        add_index :alerts, :alert_definition_id
			end
    end
  end

  def self.down
    exists = Alert.table_exists? rescue false
    if exists
      transaction do
				drop_table :alerts
			end
		end
  end
end
