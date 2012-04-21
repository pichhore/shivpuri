class AddPrivacyFieldToEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :privacy, :string
  end

  def self.down
    drop_column :profile_field_engine_indices, :privacy
  end
end
