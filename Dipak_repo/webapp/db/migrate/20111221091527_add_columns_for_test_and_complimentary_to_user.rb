class AddColumnsForTestAndComplimentaryToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :test_comp, :string
    add_column :users, :complimentary_reason, :text
  end

  def self.down
    remove_column :users, :test_comp
    remove_column :users, :complimentary_reason
  end
end
