class AddMyDwellgoTip < ActiveRecord::Migration
  def self.up
    Tip.create!({ :tip_text=>"Go directly to your New matches by clicking 'New' within a profile", :target_page=>"my_dwellgo"})
  end

  def self.down
    # not gonna undo it
  end
end
