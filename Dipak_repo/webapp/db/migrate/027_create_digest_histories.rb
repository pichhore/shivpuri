class CreateDigestHistories < ActiveRecord::Migration
  def self.up
    exists = DigestHistory.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table digest_histories..."
        create_table :digest_histories, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :user_id, :string, :limit => 36, :null => false
          t.column :digest_sent_flag, :string, :limit=>1, :null => false
          t.column :last_process_date, :datetime, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE digest_histories ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = DigestHistory.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table digest_histories..."
        drop_table :digest_histories
      end
    end
  end
end
