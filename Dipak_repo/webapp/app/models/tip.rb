class Tip < ActiveRecord::Base
  uses_guid

  validates_presence_of     :tip_text
  validates_presence_of     :target_page

  def self.find_next_tip_with_index(target_page,last_index_used=nil)
    last_index_used = -1 if last_index_used.nil?
    tips_for_page = self.find(:all, :conditions=>["target_page = ?",target_page.to_s], :order=>"created_at DESC")
    next_index = last_index_used + 1
    next_index = 0 if next_index >= tips_for_page.length
    return tips_for_page[next_index], next_index
  end
end
