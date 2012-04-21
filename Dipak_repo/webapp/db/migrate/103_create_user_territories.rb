class CreateUserTerritories < ActiveRecord::Migration
  def self.up
    exists = UserTerritory.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table user_territories..."
        create_table "user_territories", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_id, :string, :limit => 36
            t.column :territory_id, :string, :limit => 36
        end

        puts "Setting primary key"
        execute "ALTER TABLE user_territories ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :user_territories
  end
end