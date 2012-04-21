class AddDeleteReasonColumnToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :delete_reason, :text
  end

  def self.down
    remove_column :profiles, :delete_reason
  end
end
