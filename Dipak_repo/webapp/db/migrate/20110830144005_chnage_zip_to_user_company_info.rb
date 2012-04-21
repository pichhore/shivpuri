class ChnageZipToUserCompanyInfo < ActiveRecord::Migration
  def self.up
    change_column :user_company_infos, :zipcode, :string,  :limit => 7
  end

  def self.down
    change_column :user_company_infos, :zipcode, :string,  :limit => 5
  end
end
