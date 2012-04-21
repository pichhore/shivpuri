class CreateApplicationTransactions < ActiveRecord::Migration
  def self.up
    create_table :application_transactions do |t|
      t.integer :application_id
      t.string :action
      t.integer :amount
      t.boolean :success
      t.string :authorization
      t.string :message
      t.text :params

      t.timestamps
    end
  end

  def self.down
    drop_table :application_transactions
  end
end
