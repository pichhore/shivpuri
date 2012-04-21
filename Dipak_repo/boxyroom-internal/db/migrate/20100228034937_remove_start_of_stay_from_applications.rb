class RemoveStartOfStayFromApplications < ActiveRecord::Migration
  def self.up
    remove_column :applications, :start_of_stay
  end

  def self.down
    add_column :applications, :start_of_stay, :date
  end
end
