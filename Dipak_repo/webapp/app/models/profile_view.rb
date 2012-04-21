class ProfileView < ActiveRecord::Base
  uses_guid
  acts_as_paranoid

  belongs_to :profile
  belongs_to :viewed_by_profile,   :class_name => 'Profile', :foreign_key => 'viewed_by_profile_id'
end
