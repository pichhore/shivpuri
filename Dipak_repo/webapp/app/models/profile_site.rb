class ProfileSite < ActiveRecord::Base

  belongs_to :profile
  validates_uniqueness_of :site_id, :scope => :profile_id

  named_scope :sites_to_syndicate_for_profile, lambda{ |profile_id| 
    { :conditions => { :profile_id => profile_id, :syndicated => false} }
  }

  named_scope :sites_syndicated_for_profile, lambda{ |profile_id| 
    { :conditions => { :profile_id => profile_id, :syndicated => true} }
  }
  
  class << self
    def add(profile_id, site_id)
      return false if profile_id.blank? || site_id.blank?
      profile_site = ProfileSite.new(:profile_id => profile_id, :site_id => site_id)
      profile_site.save
    end
  end

  def self.update_site_settings profile_id, sites
    self.find_all_by_profile_id(profile_id).each{ |ps|
      ps.update_attributes({:syndicated => false, :updated_at => Time.now}) if sites.has_value?(ps.site_id.to_s)
    }
    
    sites_array = self.find_all_by_profile_id(profile_id).map{|x| x.site_id.to_s}
    sites.each{|k,v| self.add(profile_id, v) if !sites_array.include?(v)}
  end
end
