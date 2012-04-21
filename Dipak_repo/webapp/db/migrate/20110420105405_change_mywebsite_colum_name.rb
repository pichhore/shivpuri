class ChangeMywebsiteColumName < ActiveRecord::Migration
  def self.up
    rename_column :my_websites,:site,:site_id
  end

  def self.down
    rename_column :my_websites,:site_id,:site
  end
end
