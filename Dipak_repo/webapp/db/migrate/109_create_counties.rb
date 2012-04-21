class CreateCounties < ActiveRecord::Migration
  def self.up
    exists = County.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table counties... name , territory_id"
        create_table "counties", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :name, :string
            t.column :territory_id, :string, :limit => 36
        end

        puts "Setting primary key"
        execute "ALTER TABLE counties ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    drop_table :counties
  end
end
