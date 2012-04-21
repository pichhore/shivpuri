class ChangeTextToMediumtextInSuperContractIntegration < ActiveRecord::Migration
  def self.up
   change_column :super_contract_integrations, :contract, :mediumtext
  end

  def self.down
  end
end
