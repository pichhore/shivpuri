class CreatePartnerAccounts < ActiveRecord::Migration
  def self.up
    create_table :partner_accounts do |t|
      t.column :user_id, :string, :limit => 36, :null => false, :references => nil
      t.column :permalink, :string
    end
  end
  
  def self.down
    drop_table :partner_accounts
  end
end
