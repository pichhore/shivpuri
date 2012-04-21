class FeaturedProfile < ActiveRecord::Base
  uses_guid

  belongs_to :profile

  PROFILES_PER_TYPE = 3

  def self.find_buyers
    return FeaturedProfile.find(:all, :conditions=>["profile_type = 'buyer'"])
  end

  def self.find_owners
    return FeaturedProfile.find(:all, :conditions=>["profile_type = 'owner'"])
  end

  def self.refresh
    begin
      FeaturedProfile.delete_all
      buyer_profiles = Profile.find_featured_profiles("buyer", PROFILES_PER_TYPE)
      buyer_profiles.each_with_index { |bp, index| FeaturedProfile.create!(:profile_type=>"buyer", :profile_id=>bp.id) if index <=2 }
  
      owner_profiles = Profile.find_featured_profiles("owner", PROFILES_PER_TYPE)
      owner_profiles.each_with_index { |bp, index| FeaturedProfile.create!(:profile_type=>"owner", :profile_id=>bp.id) if index <=2 }
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"FeaturedProfile")
    end
  end
end
