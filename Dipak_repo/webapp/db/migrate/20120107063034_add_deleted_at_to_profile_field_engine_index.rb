class AddDeletedAtToProfileFieldEngineIndex < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :deleted_at, :datetime
  end

  def self.down
    remove_column :profile_field_engine_indices, :deleted_at
  end
end
