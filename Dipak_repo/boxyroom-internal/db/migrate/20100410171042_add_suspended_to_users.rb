class AddSuspendedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suspended, :boolean, :default => false

    User.all.each do |u|
      u.suspended = false
      u.save
    end
  end

  def self.down
    remove_column :users, :suspended
  end
end
