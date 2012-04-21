class AddPropertyTypeSortOrderToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :property_type_sort_order, :integer
    ProfileFieldEngineIndex.refresh_indices
  end

  def self.down
    remove_column :profile_field_engine_indices, :property_type_sort_order
  end
end
