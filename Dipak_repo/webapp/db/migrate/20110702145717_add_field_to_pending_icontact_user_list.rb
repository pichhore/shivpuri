class AddFieldToPendingIcontactUserList < ActiveRecord::Migration
  def self.up
    add_column :pending_icontact_user_lists, :is_processed, :boolean, :default => false
  end

  def self.down
    remove_column :pending_icontact_user_lists, :is_processed
  end
end
