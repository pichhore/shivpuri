class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    exists = Feedback.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table feedbacks..."
        create_table "feedbacks", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :user_id, :string, :limit => 36, :references => :users
          t.column :first_name, :string
          t.column :last_name, :string
          t.column :email, :string
          t.column :ip_address, :string
          t.column :comments, :text
          t.column :cgi_env, :text
          t.column :created_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE feedbacks ADD PRIMARY KEY (id)"

      end
    end
  end

  def self.down
    exists = Feedback.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table feedbacks..."
        drop_table :feedbacks
      end
    end
  end
end
