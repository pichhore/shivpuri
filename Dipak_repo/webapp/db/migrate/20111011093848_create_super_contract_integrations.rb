class CreateSuperContractIntegrations < ActiveRecord::Migration
  def self.up
    create_table :super_contract_integrations do |t|
      t.string :state_id
      t.text :contract
      t.timestamps
    end
  end

  def self.down
    drop_table :super_contract_integrations
  end
end
