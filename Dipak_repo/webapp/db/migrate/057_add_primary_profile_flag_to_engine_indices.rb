class AddPrimaryProfileFlagToEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :is_primary_profile, :boolean, :default=>false
#    add_column :profile_field_engine_indices, :profile_created_at, :datetime
    add_column :profile_field_engine_indices, :has_features, :boolean, :default=>false
    add_column :profile_field_engine_indices, :has_description, :boolean, :default=>false
    add_column :profile_field_engine_indices, :profile_type_id, :string, :limit => 36
    add_column :profile_field_engine_indices, :user_id, :string, :limit => 36

    add_index :profile_field_engine_indices, :is_primary_profile
    add_index :profile_field_engine_indices, :profile_created_at
    add_index :profile_field_engine_indices, :has_features
    add_index :profile_field_engine_indices, :has_description
    add_index :profile_field_engine_indices, :profile_type_id
    add_index :profile_field_engine_indices, :user_id
  end

  def self.down
    remove_column :profile_field_engine_indices, :is_primary_profile
    remove_column :profile_field_engine_indices, :profile_created_at
    remove_column :profile_field_engine_indices, :has_features
    remove_column :profile_field_engine_indices, :has_description
    remove_column :profile_field_engine_indices, :profile_type_id
    remove_column :profile_field_engine_indices, :user_id
  end
end
