class AddColumnCommentToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :add_user_comment, :text
  end

  def self.down
    remove_column :users, :add_user_comment
  end
end
