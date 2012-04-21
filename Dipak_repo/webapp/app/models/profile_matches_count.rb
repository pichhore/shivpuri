class ProfileMatchesCount < ActiveRecord::Base
  uses_guid
  belongs_to :profile
  
  class << self
    def update_profile_matches(pmd, profile_id)
      pmc = ProfileMatchesCount.find_by_profile_id(profile_id)
      pmc.decrease unless pmc.nil?
      pmd.destroy unless pmd.nil?
    end
  end
  
  def increase
    self.update_attribute(:count, self.count+1)
  end

  def decrease
    self.update_attribute(:count, self.count-1)
  end
end
