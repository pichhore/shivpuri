class AddAgentEmailColumnToSyndicateProperties < ActiveRecord::Migration
  def self.up
    add_column :syndicate_properties, :agent_email, :string
  end

  def self.down
    remove_column :syndicate_properties, :agent_email
  end
end
