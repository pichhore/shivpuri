class AddFieldInActivityLogTableForSellerProfile < ActiveRecord::Migration
  def self.up
    execute "INSERT into activity_categories (id, name) VALUES ('cat_seller_prof_deleted', 'Seller Profile Deleted')"
    add_column :activity_logs, :seller_profile_id, :string, :limit => 36, :null => true
    add_column :seller_profiles, :admin_delete_comment, :text
    add_column :activity_logs, :seller_profile_name, :text
  end

  def self.down
    execute "DELETE FROM activity_categories where id ='cat_seller_prof_deleted'"
    remove_column :activity_logs, :seller_profile_id
    remove_column :seller_profiles, :admin_delete_comment
    remove_column :activity_logs, :seller_profile_name, :text
  end
end