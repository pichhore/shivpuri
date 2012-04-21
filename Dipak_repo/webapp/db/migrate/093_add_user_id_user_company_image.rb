class AddUserIdUserCompanyImage < ActiveRecord::Migration
  def self.up
    add_column :user_company_images, :user_id, :string, :limit => 36, :null => false
  end

  def self.down
    remove_column :user_company_images, :user_id
  end
end
