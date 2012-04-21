#
# FK support via a plugin from http://www.redhillonrails.org/#foreign_key_migrations
#
class CreateProfiles < ActiveRecord::Migration
  def self.up
    exists = Profile.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profiles..."
        create_table :profiles, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_type_id, :string, :limit => 36, :null => false
          t.column :user_id, :string, :limit => 36, :references => nil
          t.column :name, :string, :null => false
          t.column :permalink, :string, :null => false
          t.column :created_at, :datetime
          t.column :updated_at, :datetime
          t.column :deleted_at, :datetime # acts_as_paranoid
        end

        puts "Setting primary key"
        execute "ALTER TABLE profiles ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'permalink'"
        add_index :profiles, :permalink, :unique => true

        puts "Adding indexed column 'profile_type_id'"
        add_index :profiles, :profile_type_id

        puts "Adding indexed column 'user_id'"
        add_index :profiles, :user_id
      end
    end
  end

  def self.down
    exists = Profile.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profiles..."
        drop_table :profiles
      end
    end
  end
end
