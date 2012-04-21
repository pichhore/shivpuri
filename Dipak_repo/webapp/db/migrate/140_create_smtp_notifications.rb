class CreateSmtpNotifications < ActiveRecord::Migration
  def self.up
    create_table :smtp_notifications do |t|
      t.string :event
      t.string :email
      t.string :category
      t.string :reason
      t.string :attempt
      t.string :type
      t.string :status
      t.string :url
      t.string :response

      t.timestamps
    end
  end

  def self.down
    drop_table :smtp_notifications
  end
end
