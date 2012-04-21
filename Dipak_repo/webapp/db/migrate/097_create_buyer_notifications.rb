class CreateBuyerNotifications < ActiveRecord::Migration
  def self.up
    create_table :buyer_notifications do |t|
      t.string :user_id
      t.string :summary_type
      t.text :email_intro
      t.text :email_closing

      t.timestamps
    end
  end

  def self.down
    drop_table :buyer_notifications
  end
end
