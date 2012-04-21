class CreateThreads < ActiveRecord::Migration
  def self.up
    create_table :message_threads do |t|

      t.string :title
      t.string :code

      t.integer :owner_id
      t.integer :participant_id
      t.integer :property_id

      t.datetime :last_accessed

      t.timestamps
    end

    add_index :message_threads, :code, :unique => true
  end

  def self.down
    drop_table :message_threads
  end
end
