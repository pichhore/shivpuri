class CreateStates < ActiveRecord::Migration
  def self.up
    exists = State.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table states..."
        create_table "states", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :name, :string
            t.column :state_code, :string
        end

        puts "Setting primary key"
        execute "ALTER TABLE states ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :states
  end
end
