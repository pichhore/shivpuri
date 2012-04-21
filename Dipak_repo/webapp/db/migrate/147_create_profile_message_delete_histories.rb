class CreateProfileMessageDeleteHistories < ActiveRecord::Migration
  def self.up
    create_table :profile_message_delete_histories do |t|
      t.string :subject
      t.string :deleted_by
      t.string :sender

      t.timestamps
    end
  end

  def self.down
    drop_table :profile_message_delete_histories
  end
end
