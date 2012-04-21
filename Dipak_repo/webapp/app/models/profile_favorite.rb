class ProfileFavorite < ActiveRecord::Base
  uses_guid
  acts_as_paranoid

  belongs_to :profile
  belongs_to :target_profile, :class_name => 'Profile', :foreign_key => 'target_profile_id'

  validates_presence_of :target_profile
end
