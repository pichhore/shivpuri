class AddOwnerDashboardTip < ActiveRecord::Migration
  def self.up
    Tip.create!({ :tip_text=>"Click 'Preview My Profile' to see how a buyer sees your property", :target_page=>"owner_dashboard"})

  end

  def self.down
    # not gonna undo it
  end
end
