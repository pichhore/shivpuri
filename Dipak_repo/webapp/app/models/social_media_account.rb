class SocialMediaAccount < ActiveRecord::Base
  URL_TYPE = {
    :FACEBOOK => 1,
    :LINKEDIN => 2,
    :YOUTUBE  => 3,
    :TWITTER  => 4
  }

  SITE_TYPE ={
    :BUYER_WEBSITE  => 1,
    :SELLER_WEBSITE => 2
  }

  belongs_to :user

  class << self
    def add(url, user_id, url_type_id, site_type_id)
      return false if user_id.blank? || url_type_id.blank? || site_type_id.blank?
      media_acc = SocialMediaAccount.find(:first, :conditions => {:user_id => user_id, :url_type_id => url_type_id, :site_type_id => site_type_id})
      media_acc = SocialMediaAccount.new(:user_id => user_id, :url_type_id => url_type_id, :site_type_id => site_type_id) if media_acc.nil?
      media_acc.url = url
      media_acc.save!
    end
  end
  
end
