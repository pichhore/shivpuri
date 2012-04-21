class AddEmailFieldsToBagdes < ActiveRecord::Migration
  def self.up
   add_column :badges, :email_subject,  :text
   add_column :badges, :email_body,     :text
  end

  def self.down
   add_column :badges, :email_subject
   add_column :badges, :email_body
  end
end
