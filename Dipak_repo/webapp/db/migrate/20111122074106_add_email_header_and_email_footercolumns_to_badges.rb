class AddEmailHeaderAndEmailFootercolumnsToBadges < ActiveRecord::Migration
  def self.up
    add_column :badges, :email_header,  :text
    add_column :badges, :email_footer,  :text
  end

  def self.down
    remove_column :badges, :email_header
    remove_column :badges, :email_footer
  end
end
