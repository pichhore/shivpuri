class UserCompanyInfoZipIntToString < ActiveRecord::Migration
  def self.up
    change_column :user_company_infos,:zipcode,:string,:limit=>5
  end

  def self.down
    remove_column :user_company_infos, :zipcode, :integer,:limit=>5
  end
end
