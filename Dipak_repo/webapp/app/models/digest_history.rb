class DigestHistory < ActiveRecord::Base
  uses_guid
  belongs_to :user

  def self.find_last_digest_sent_history(user)
    return nil if user.nil?
    return self.find(:first, :conditions=>["user_id = ? AND digest_sent_flag = 'Y'", user.id], :order=>"last_process_date DESC")
  end

  def self.find_last_history(user)
    return nil if user.nil?
    return self.find(:first, :conditions=>["user_id = ?", user.id], :order=>"last_process_date DESC")
  end

  def digest_sent?
    return self.digest_sent_flag == "Y"
  end
end
