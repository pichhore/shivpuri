class CreateProfileMessages < ActiveRecord::Migration

  def self.up
    exists = ProfileMessage.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_messages..."
        create_table "profile_messages", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :from_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :to_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :body, :text
          t.column :created_at, :datetime
          t.column :viewed_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_messages ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ProfileMessage.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_messages..."
        drop_table :profile_messages
      end
    end
  end
end
