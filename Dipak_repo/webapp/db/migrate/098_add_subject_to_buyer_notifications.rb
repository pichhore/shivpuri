class AddSubjectToBuyerNotifications < ActiveRecord::Migration
  def self.up
    add_column :buyer_notifications, :subject, :text
  end

  def self.down
    remove_column :buyer_notifications, :subject
  end
end
