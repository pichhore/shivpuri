class CreateUsers < ActiveRecord::Migration
  def self.up
    exists = User.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table users..."
        create_table "users", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :login,                     :string
          t.column :email,                     :string
          t.column :first_name,                :string
          t.column :last_name,                 :string
          t.column :home_phone,                :string
          t.column :business_phone,            :string
          t.column :mobile_phone,              :string
          t.column :crypted_password,          :string, :limit => 40
          t.column :salt,                      :string, :limit => 40
          t.column :created_at,                :datetime
          t.column :updated_at,                :datetime
          t.column :remember_token,            :string
          t.column :remember_token_expires_at, :datetime

          t.column :activation_code, :string, :limit => 40
          t.column :activated_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE users ADD PRIMARY KEY (id)"

        puts "Adding indexed column 'login'"
        add_index :users, :login, :unique => true
      end
    end
  end

  def self.down
    exists = User.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table users..."
        drop_table :users
      end
    end
  end
end
