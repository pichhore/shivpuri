class ProfileMessage < ActiveRecord::Base
  uses_guid
  has_many :profile_message_recipients
  belongs_to :reply_to_profile_message, :foreign_key=> :reply_to_profile_message_id, :class_name=>"ProfileMessage"

  def self.count_messages(time)
    return ProfileMessageRecipient.count_by_sql("select count(pm.id) from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id and DATE(pm.created_at) < '#{time.strftime("%Y-%m-%d")}' and pmr.from_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp')) AND pmr.to_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp'))")
  
#    return self.count('id', { :conditions=>["DATE(created_at) < '#{time.strftime("%Y-%m-%d")}'"]})
  end

  def display_subject
    return self.subject.nil? ? "(none)" : self.subject[0..99]
  end
end
