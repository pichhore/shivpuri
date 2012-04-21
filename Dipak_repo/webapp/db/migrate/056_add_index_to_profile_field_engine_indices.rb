class AddIndexToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    add_index :profile_field_engine_indices, :is_owner
    add_index :profile_field_engine_indices, :property_type
    add_index :profile_field_engine_indices, :beds
    add_index :profile_field_engine_indices, :baths
    add_index :profile_field_engine_indices, :square_feet
    add_index :profile_field_engine_indices, :square_feet_min
    add_index :profile_field_engine_indices, :square_feet_max
    add_index :profile_field_engine_indices, :price
    add_index :profile_field_engine_indices, :price_min
    add_index :profile_field_engine_indices, :price_max
    add_index :profile_field_engine_indices, :units
    add_index :profile_field_engine_indices, :units_min
    add_index :profile_field_engine_indices, :units_max
    add_index :profile_field_engine_indices, :acres
    add_index :profile_field_engine_indices, :acres_min
    add_index :profile_field_engine_indices, :acres_max
    add_index :profile_field_engine_indices, :privacy
    add_index :profile_field_engine_indices, :property_type_sort_order
    add_index :profile_field_engine_indices, :has_profile_image
  end

  def self.down
    remove_index :profile_field_engine_indices, :is_owner
    remove_index :profile_field_engine_indices, :property_type
    remove_index :profile_field_engine_indices, :beds
    remove_index :profile_field_engine_indices, :baths
    remove_index :profile_field_engine_indices, :square_feet
    remove_index :profile_field_engine_indices, :square_feet_min
    remove_index :profile_field_engine_indices, :square_feet_max
    remove_index :profile_field_engine_indices, :price
    remove_index :profile_field_engine_indices, :price_min
    remove_index :profile_field_engine_indices, :price_max
    remove_index :profile_field_engine_indices, :units
    remove_index :profile_field_engine_indices, :units_min
    remove_index :profile_field_engine_indices, :units_max
    remove_index :profile_field_engine_indices, :acres
    remove_index :profile_field_engine_indices, :acres_min
    remove_index :profile_field_engine_indices, :acres_max
    remove_index :profile_field_engine_indices, :privacy
    remove_index :profile_field_engine_indices, :property_type_sort_order
    remove_index :profile_field_engine_indices, :has_profile_image
  end
end
