class CreateTerritories < ActiveRecord::Migration
  def self.up
    exists = Territory.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table territories..."
        create_table "territories", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :territory_name, :string
        end

        puts "Setting primary key"
        execute "ALTER TABLE territories ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :territories
  end
end
