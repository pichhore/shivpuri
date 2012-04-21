class AddFieldsInProfilesTable < ActiveRecord::Migration
  def self.up
    add_column :profiles, :contact_name, :string
    add_column :profiles, :contact_phone, :string
  end

  def self.down
    remove_column :profiles, :contact_name
    remove_column :profiles, :contact_phone
  end
end
