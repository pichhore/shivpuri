class AddImageIdUserCompanyInfo < ActiveRecord::Migration
  def self.up
    add_column :user_company_infos, :user_company_image_id, :string, :limit => 36, :null => false
    remove_column :user_company_images , :user_company_info_id
  end

  def self.down
    add_column :user_company_images , :user_company_info_id, :string, :limit => 36, :null => false
    remove_column :user_company_infos, :user_company_image_id
  end
end
