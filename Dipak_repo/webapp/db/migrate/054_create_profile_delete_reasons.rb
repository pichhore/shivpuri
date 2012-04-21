class CreateProfileDeleteReasons < ActiveRecord::Migration
  def self.up
    exists = ProfileDeleteReason.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_delete_reasons..."
        create_table :profile_delete_reasons, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_type_id, :string, :limit => 36, :null => false
          t.column :name, :string
          t.column :created_at, :datetime, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_delete_reasons ADD PRIMARY KEY (id)"

        # Owner profile reasons
        execute "INSERT into profile_delete_reasons (id, profile_type_id, name, created_at) values ('sold_dwellgo','ce5c2320-4131-11dc-b432-009096fa4c28', 'Sold through Dwellgo',now())"
        execute "INSERT into profile_delete_reasons (id, profile_type_id, name, created_at) values ('sold_elsewhere','ce5c2320-4131-11dc-b432-009096fa4c28', 'Sold elsewhere',now())"

        # Buyer profile reasons
        execute "INSERT into profile_delete_reasons (id, profile_type_id, name, created_at) values ('bought_dwellgo','ce5c2320-4131-11dc-b431-009096fa4c28', 'Bought through Dwellgo',now())"
        execute "INSERT into profile_delete_reasons (id, profile_type_id, name, created_at) values ('bought_elsewhere','ce5c2320-4131-11dc-b431-009096fa4c28', 'Bought elsewhere',now())"
      end
    end
  end

  def self.down
    exists = ProfileDeleteReason.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_delete_reasons..."
        drop_table :profile_delete_reasons
      end
    end
  end
end
