class Invitation < ActiveRecord::Base
  uses_guid

  validates_presence_of :to_email
  validates_presence_of :invitation_message

  def email
    return self.to_email
  end

  def salutation
    return self.to_first_name if !self.to_first_name.nil? and !self.to_first_name.empty?
    return self.to_email
  end
end
