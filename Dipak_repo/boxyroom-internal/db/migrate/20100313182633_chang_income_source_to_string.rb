class ChangIncomeSourceToString < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :income_source
    add_column :profiles, :income_source, :string
  end

  def self.down
    remove_column :profiles, :income_source
    add_column :profiles, :income_source, :integer
  end
end
