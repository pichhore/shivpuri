class CreateUserCompanyInfos < ActiveRecord::Migration
  def self.up
      exists = UserCompanyInfo.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table user_company_infos..."
        create_table "user_company_infos", :id => false do |t|
            t.column :id, :string, :limit => 36, :null => false
            t.column :user_id, :string, :limit => 36, :null => false, :references => :users
            t.column :created_at, :datetime
            t.column :business_name, :string, :null => false
            t.column :business_address, :string, :null => false
            t.column :business_phone, :string, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE user_company_infos ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    drop_table :user_company_infos
  end
end
