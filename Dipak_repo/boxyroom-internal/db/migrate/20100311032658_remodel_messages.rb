class RemodelMessages < ActiveRecord::Migration
  def self.up
    drop_table :messages

    create_table :messages do |t|

      t.string :subject
      t.text :body

      t.integer :sender_id
      t.integer :recipient_id
      t.integer :thread_id

      t.datetime :sent_at

      t.timestamps
    end
  end

  def self.down
    drop_table :messages

    create_table :messages do |t|

      t.string :subject
      t.text :body

      t.boolean :read, :default => false

      t.string :sender_type
      t.integer :sender_id

      t.string :receiver_type
      t.integer :receiver_id

      t.boolean :trashed_by_sender, :default => false
      t.boolean :trashed_by_receiver, :default => false

      t.timestamps
    end
  end
end
