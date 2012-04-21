class CreateInvestorMessageRecipients < ActiveRecord::Migration
  def self.up
    create_table :investor_message_recipients do |t|
      t.integer :investor_message_id
      t.string :reciever_id,:limit => 36, :references =>  :users

      t.timestamps
    end
  end

  def self.down
    drop_table :investor_message_recipients
  end
end
