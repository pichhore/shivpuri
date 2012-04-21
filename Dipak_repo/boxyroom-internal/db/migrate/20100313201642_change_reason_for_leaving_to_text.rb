class ChangeReasonForLeavingToText < ActiveRecord::Migration
  def self.up
    change_column :applications, :reason_for_leaving, :text
  end

  def self.down
    change_column :applications, :reason_for_leaving, :string
  end
end
