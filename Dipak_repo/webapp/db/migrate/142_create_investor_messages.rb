class CreateInvestorMessages < ActiveRecord::Migration
  def self.up
    create_table :investor_messages do |t|
      t.string :subject
      t.text :body
      t.string :sender_id, :limit => 36, :references =>  :users

      t.timestamps
    end
  end

  def self.down
    drop_table :investor_messages
  end
end
