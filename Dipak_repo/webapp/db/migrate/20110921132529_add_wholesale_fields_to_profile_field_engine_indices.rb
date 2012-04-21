class AddWholesaleFieldsToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :investment_type_id, :integer, :null => false, :default => 1, :references => :investment_types
    add_column :profile_field_engine_indices, :after_repair_value, :integer, :null => false
    add_column :profile_field_engine_indices, :value_determined_by, :text, :null => false
    add_column :profile_field_engine_indices, :total_repair_needed, :integer, :null => false
    add_column :profile_field_engine_indices, :repair_calculated_by, :text, :null => false
    add_column :profile_field_engine_indices, :max_purchase_value, :integer, :null => false
    add_column :profile_field_engine_indices, :arv_repairs_value, :integer, :null => false
  end

  def self.down
    remove_column :profile_field_engine_indices, :investment_type_id
    remove_column :profile_field_engine_indices, :after_repair_value
    remove_column :profile_field_engine_indices, :value_determined_by
    remove_column :profile_field_engine_indices, :total_repair_needed
    remove_column :profile_field_engine_indices, :repair_calculated_by
    remove_column :profile_field_engine_indices, :max_purchase_value
    remove_column :profile_field_engine_indices, :arv_repairs_value
  end
end
