class SiteUser < ActiveRecord::Base

validates_uniqueness_of :site_id, :scope => :user_id

  class << self
    def add(user_id, site_id)
      return false if user_id.blank? || site_id.blank?
      site_user = SiteUser.new(:user_id => user_id, :site_id => site_id)
      site_user.save
    end
  end
  
end
