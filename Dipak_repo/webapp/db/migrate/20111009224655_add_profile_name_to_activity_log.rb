class AddProfileNameToActivityLog < ActiveRecord::Migration
  def self.up
    add_column :activity_logs, :profile_name, :string
  end

  def self.down
    remove_column :activity_logs, :profile_name
  end
end
