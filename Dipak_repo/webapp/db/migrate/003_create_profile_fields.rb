class CreateProfileFields < ActiveRecord::Migration
  def self.up
    exists = ProfileField.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_fields..."
        create_table :profile_fields, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_id, :string, :limit => 36, :null => false
          t.column :key, :string, :null => false
          t.column :value, :string # may be a shortened version of value_text if it is :description, et. al.
          t.column :value_text, :text # may be null, unless the field is a description or some other clob
          t.column :created_at, :datetime
          t.column :updated_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_fields ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'key'"
        add_index :profile_fields, :key, :unique => false
        puts "Adding indexed column 'value'"
        add_index :profile_fields, :value, :unique => false
      end
    end
  end

  def self.down
    exists = ProfileField.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_fields..."
        drop_table :profile_fields
      end
    end
  end
end
