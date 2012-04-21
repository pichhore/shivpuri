class AddStatusToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :status, :string, :default => "active"
  end

  def self.down
    drop_column :profile_field_engine_indices, :status, :string
  end
end
