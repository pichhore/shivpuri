class AddOptionalRetailBuyeeFieldIndices < ActiveRecord::Migration
  def self.up
      add_column :retail_profile_field_engine_indices, :stories, :string
      add_column :retail_profile_field_engine_indices, :garage, :string
      add_column :retail_profile_field_engine_indices, :livingrooms, :string
      add_column :retail_profile_field_engine_indices, :waterfront, :string
      add_column :retail_profile_field_engine_indices, :pool, :string
      add_column :retail_profile_field_engine_indices, :water, :string
      add_column :retail_profile_field_engine_indices, :sewer, :string
      add_column :retail_profile_field_engine_indices, :electricity, :string
      add_column :retail_profile_field_engine_indices, :natural_gas, :string
      add_column :retail_profile_field_engine_indices, :trees, :string
 end

  def self.down
      remove_column :retail_profile_field_engine_indices, :stories
      remove_column :retail_profile_field_engine_indices, :garage
      remove_column :retail_profile_field_engine_indices, :livingrooms
      remove_column :retail_profile_field_engine_indices, :waterfront
      remove_column :retail_profile_field_engine_indices, :pool
      remove_column :retail_profile_field_engine_indices, :water
      remove_column :retail_profile_field_engine_indices, :sewer
      remove_column :retail_profile_field_engine_indices, :electricity
      remove_column :retail_profile_field_engine_indices, :natural_gas
      remove_column :retail_profile_field_engine_indices, :trees
  end
end
