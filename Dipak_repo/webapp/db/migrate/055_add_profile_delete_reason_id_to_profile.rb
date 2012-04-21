class AddProfileDeleteReasonIdToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :profile_delete_reason_id, :string, :limit => 36, :references=>nil
  end

  def self.down
    remove_column :profiles, :profile_delete_reason_id
  end
end
