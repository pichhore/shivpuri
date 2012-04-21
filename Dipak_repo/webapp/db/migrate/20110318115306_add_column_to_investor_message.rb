class AddColumnToInvestorMessage < ActiveRecord::Migration
  def self.up
    add_column :investor_messages, :marked_as_spam, :boolean, :default => false

  end

  def self.down
    remove_column :investor_messages, :marked_as_spam
  end
end
