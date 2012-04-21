class RemoveUserCompanyInfoImageDependency < ActiveRecord::Migration
  def self.up
    remove_column :user_company_infos, :user_company_image_id
  end

  def self.down
    add_column :user_company_infos, :user_company_image_id,:string, :limit => 36, :null => false
  end
end
