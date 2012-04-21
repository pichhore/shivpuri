class CreateProfileTypes < ActiveRecord::Migration
  def self.up
    exists = ProfileType.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_types..."
        create_table :profile_types, :id => false do |t|
          t.column :id, :string, :limit => 36
          t.column :name, :string
          t.column :permalink, :string
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_types ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'permalink'"
        add_index :profile_types, :permalink, :unique => true

        puts "Inserting profile_type 'buyer' with uuid 'ce5c2320-4131-11dc-b431-009096fa4c28'"
        execute "INSERT INTO profile_types (id, name, permalink) values ('ce5c2320-4131-11dc-b431-009096fa4c28','buyer','buyer')"
        puts "Inserting profile_type 'owner' with uuid 'ce5c2320-4131-11dc-b432-009096fa4c28'"
        execute "INSERT INTO profile_types (id, name, permalink) values ('ce5c2320-4131-11dc-b432-009096fa4c28','owner','owner')"
        puts "Inserting profile_type 'buyer-agent' with uuid 'ce5c2320-4131-11dc-b433-009096fa4c28'"
        execute "INSERT INTO profile_types (id, name, permalink) values ('ce5c2320-4131-11dc-b433-009096fa4c28','buyer-agent','buyer-agent')"
        puts "Inserting profile_type 'seller-agent' with uuid 'ce5c2320-4131-11dc-b434-009096fa4c28'"
        execute "INSERT INTO profile_types (id, name, permalink) values ('ce5c2320-4131-11dc-b434-009096fa4c28','seller-agent','seller-agent')"
        puts "Inserting profile_type 'service-provider' with uuid 'ce5c2320-4131-11dc-b435-009096fa4c28'"
        execute "INSERT INTO profile_types (id, name, permalink) values ('ce5c2320-4131-11dc-b435-009096fa4c28','service-provider','service-provider')"
      end
    end
  end

  def self.down
    exists = ProfileType.table_exists? rescue false
    if exists
      transaction do
        puts "Removing table profile_types..."
        drop_table :profile_types

      end
    end
  end
end
