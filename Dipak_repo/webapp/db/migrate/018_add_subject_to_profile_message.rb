class AddSubjectToProfileMessage < ActiveRecord::Migration
  def self.up
    add_column :profile_messages, :subject, :string
  end

  def self.down
    drop_column :profile_messages, :subject
  end
end
