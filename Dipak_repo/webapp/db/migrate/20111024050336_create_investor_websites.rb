class CreateInvestorWebsites < ActiveRecord::Migration
  def self.up
    exists = InvestorWebsite.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table investor_websites..."
        create_table :investor_websites, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :user_id, :string, :limit => 36, :null => false, :references => :users
          t.column :header,                    :string
          t.column :permalink_text,            :string
          t.column :dynamic_css,               :string
          t.column :home_page_text,            :text
          t.column :about_us_page_text,        :text
          t.column :domain_type,               :string
          t.column :ua_number,                 :string
          t.column :active,                    :boolean
          t.column :tagline,                   :string
          t.column :phone,                     :string
          t.timestamps
        end
        puts "Setting primary key"
        execute "ALTER TABLE investor_websites ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = InvestorWebsite.table_exists? rescue false
    if exists
      drop_table :investor_websites
    end
  end
end
