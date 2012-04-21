class AddCountryColumnToUserCompanyInfos < ActiveRecord::Migration
  def self.up
    add_column "user_company_infos", "country", :string , :default => "US"
  end

  def self.down
    remove_column "user_company_infos", "country"
  end
end
