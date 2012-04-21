class ChangeTextToMiddletextInProfileContractTable < ActiveRecord::Migration
  def self.up
    change_column :profile_contracts, :contract, :mediumtext
  end

  def self.down
  end
end
