class AddBusinessEmailUserCompanyInfo < ActiveRecord::Migration
  def self.up
    add_column :user_company_infos, :business_email, :string, :null => false
  end

  def self.down
    remove_column :user_company_infos, :business_email
  end
end
