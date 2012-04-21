class ProfileDeleteReason < ActiveRecord::Base
  uses_guid

  def self.find_for_profile(profile)
    return ProfileDeleteReason.find(:all, :conditions=>["profile_type_id = ?", profile.profile_type_id])
  end
end
