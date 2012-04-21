class AllowDuplicateTokenIndices < ActiveRecord::Migration
  def self.up
    remove_index :consumer_tokens, :token
    add_index :consumer_tokens, :token
  end

  def self.down
    remove_index :consumer_tokens, :token
    add_index :consumer_tokens, :token, :unique
  end
end
