class AddColumnSpamReasonToInvestorMessage < ActiveRecord::Migration
  def self.up
    add_column :investor_messages, :spam_reason, :text
  end

  def self.down
    remove_column :investor_messages, :spam_reason
  end
end
