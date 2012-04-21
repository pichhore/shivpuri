class AddAdminDeleteCommentInProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :admin_delete_comment, :text
  end

  def self.down
    remove_column :profiles, :admin_delete_comment
  end
end
