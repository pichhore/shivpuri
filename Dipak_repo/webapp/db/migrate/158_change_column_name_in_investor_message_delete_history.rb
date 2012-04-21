class ChangeColumnNameInInvestorMessageDeleteHistory < ActiveRecord::Migration
  def self.up
    rename_column :investor_message_delete_histories,:subject,:message
  end

  def self.down
    rename_column :investor_message_delete_histories,:message,:subject
  end
end