class AddDeleteProfileActivityCategory < ActiveRecord::Migration
  def self.up
    execute "INSERT into activity_categories (id, name) VALUES ('cat_prof_deleted'     ,'Profile Deleted')"
  end

  def self.down
    execute "DELETE FROM activity_categories where id ='cat_prof_deleted'"
  end
end
