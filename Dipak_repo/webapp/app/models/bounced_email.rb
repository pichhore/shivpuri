class BouncedEmail < ActiveRecord::Base
  validates_uniqueness_of :email
  
  def self.find_bounced_email_address(email)
    return BouncedEmail.find_by_email(email.to_s).blank? ? false : true
  end
end
