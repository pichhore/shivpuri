class CreateProfileMessageRecipients < ActiveRecord::Migration
  def self.up
    exists = ProfileMessageRecipient.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_message_recipient..."
        create_table "profile_message_recipients", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :from_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :to_profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :viewed_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_message_recipients ADD PRIMARY KEY (id)"

        puts "Dropping from_profile_id, to_profile_id, viewed_at columns from profile_messages"
        remove_column :profile_messages, :from_profile_id
        remove_column :profile_messages, :to_profile_id
        remove_column :profile_messages, :viewed_at
      end
    end
  end

  def self.down
    exists = ProfileMessageRecipient.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_message_recipients..."
        drop_table :profile_message_recipients
      end
    end
  end
end
