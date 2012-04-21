class CreateOauthConsumerTokens < ActiveRecord::Migration
  def self.up
    
    create_table :consumer_tokens do |t|
      t.string :user_id, :limit => 36, :references => nil, :null => false
      t.string :type, :limit => 30
      t.string :token # This has to be huge because of Yahoo's excessively large tokens
      t.string :secret
      t.timestamps
    end
    
    add_index :consumer_tokens, :token, :unique
    
  end

  def self.down
    drop_table :consumer_tokens
  end

end
