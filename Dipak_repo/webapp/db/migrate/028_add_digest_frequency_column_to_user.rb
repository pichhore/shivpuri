class AddDigestFrequencyColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :digest_frequency, :string, :limit=>1, :default=>"D"
  end

  def self.down
    drop_column :users, :digest_frequency
  end
end
