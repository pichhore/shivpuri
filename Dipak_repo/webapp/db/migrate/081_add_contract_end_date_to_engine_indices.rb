class AddContractEndDateToEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :contract_end_date, :date
  end

  def self.down
    drop_column :profile_field_engine_indices, :contract_end_date, :date
  end
end
