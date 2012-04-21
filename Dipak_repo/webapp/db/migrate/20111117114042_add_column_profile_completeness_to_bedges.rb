class AddColumnProfileCompletenessToBedges < ActiveRecord::Migration
  def self.up
    add_column :badges, :profile_completeness, :integer
  end

  def self.down
    remove_column :badges, :profile_completeness
  end
end
