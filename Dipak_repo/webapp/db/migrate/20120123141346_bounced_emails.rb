class BouncedEmails < ActiveRecord::Migration
  def self.up
    create_table :bounced_emails do |t|
      t.column :email, :string
      t.column :reason, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :bounced_emails
  end
end
