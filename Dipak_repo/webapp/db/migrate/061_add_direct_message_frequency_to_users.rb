class AddDirectMessageFrequencyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :direct_message_frequency, :string, :limit=>1, :null=>false, :default=>'I'
  end

  def self.down
    remove_column :users, :direct_message_frequency
  end
end
