class AddMaxMonDownPayementToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
      add_column :profile_field_engine_indices, :max_mon_pay, :integer
      add_column :profile_field_engine_indices, :max_dow_pay, :integer
  end

  def self.down
      remove_column :profile_field_engine_indices, :max_mon_pay
      remove_column :profile_field_engine_indices, :max_dow_pay
  end
end