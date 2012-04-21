class AddReasonForMovingToProfiles < ActiveRecord::Migration
  def self.up
   add_column :profiles, :reason_for_moving, :string
  end

  def self.down
   remove_column :profiles, :reason_for_moving
  end
end
