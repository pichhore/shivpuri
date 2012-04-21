class AddInvestmentTypeIdToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :investment_type_id, :integer, :null => false, :default => 1, :references => :investment_types
  end

  def self.down
    remove_column :profiles, :investment_type_id
  end
end
