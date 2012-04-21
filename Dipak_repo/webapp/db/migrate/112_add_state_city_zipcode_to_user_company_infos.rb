class AddStateCityZipcodeToUserCompanyInfos < ActiveRecord::Migration
  def self.up
    add_column :user_company_infos, :city, :string
    add_column :user_company_infos, :state, :string
    add_column :user_company_infos, :zipcode, :integer
  end

  def self.down
    remove_column :user_company_infos, :city
    remove_column :user_company_infos, :state
    remove_column :user_company_infos, :zipcode    
  end
end
