class CreateInitialActivityCategories < ActiveRecord::Migration
  def self.up
    execute "INSERT into activity_categories (id, name) VALUES ('cat_acct_login'     ,'Account Login')"
    execute "INSERT into activity_categories (id, name) VALUES ('cat_acct_logout'    ,'Account Logout')"
    execute "INSERT into activity_categories (id, name) VALUES ('cat_acct_created'   ,'Account Created')"
    execute "INSERT into activity_categories (id, name) VALUES ('cat_acct_activated' ,'Account Activated By Email')"

    execute "INSERT into activity_categories (id, name) VALUES ('cat_prof_created'   ,'Profile Created')"
    execute "INSERT into activity_categories (id, name) VALUES ('cat_prof_updated'   ,'Profile Updated')"
  end

  def self.down
    # remove all, since they didn't exist prior to this migration (must delete logs as well)
    execute "DELETE FROM activity_logs"
    execute "DELETE FROM activity_categories"
  end
end
