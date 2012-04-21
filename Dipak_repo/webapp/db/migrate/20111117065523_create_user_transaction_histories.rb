class CreateUserTransactionHistories < ActiveRecord::Migration
  def self.up
    create_table :user_transaction_histories do |t|
      t.column :user_id, :string, :limit => 36, :null => false, :references => :users
      t.column :transanction_detail, :string
      
      t.timestamps
    end
  end

  def self.down
    drop_table :user_transaction_histories
  end
end
