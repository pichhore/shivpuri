require "validatable"

#
# Base class for capturing ProfileMessage details from a webform, prior to creating a new ProfileMessage for the target profiles.
#
class ProfileMessageForm
  include Validatable

  FIELDS = [:send_to,
            :filters,
            :indiv_profile_id,
            :subject,
            :body,
            :reply_to_profile_message_id, 
            :from_profile_id,
           ]
  create_attrs FIELDS

  validates_presence_of :from_profile_id
  validates_presence_of :send_to
  validates_presence_of :subject
  validates_presence_of :body
  validates_presence_of :indiv_profile_id, :if => lambda { self.message_for_indiv? }, :message=>"a profile id is required for individual messaging"

  #validates_true_for    :filters, :logic => lambda { validate_filters }, :if => lambda { not self.filters.nil? and not self.filters.empty? }, :message=>""
  #def validate_filters
  #  # TODO
  #  return true
  #end

  #
  # Converts this form into a ProfileMessage model, along with child ProfileMessageRecipients
  #
  def to_profile_message(from_profile, listing_type='all', result_filter='all')
    message=[]
    profiles = Array.new
    if(check_message_for_indiv?)
      profiles << Profile.find(self.indiv_profile_id)
    else
      # find the unique list of profiles to message
      if(!filters.nil? and !filters.empty? )
        filters.each do |filter|
          profile_list,profile_count,page_count = MatchingEngine.get_matches(:profile=>from_profile, :mode=>:all, :result_filter=>filter.to_sym, :listing_type=>listing_type, :use_cache => true)

          near_profile_list,near_profile_count,near_page_count = MatchingEngine.get_near_matches(:profile=>from_profile, :mode=>:all, :result_filter=>filter.to_sym, :listing_type=>listing_type, :use_cache => true, :near_match => true)

          profiles += profile_list if profile_list.kind_of?(Array)
          profiles += near_profile_list if near_profile_list.kind_of?(Array)
        end
        profiles.uniq!
      else
        profiles,profile_count,page_count = MatchingEngine.get_matches(:profile=>from_profile, :mode=>:all, :result_filter=>result_filter.to_sym, :listing_type=>listing_type,:use_cache => true)
        near_profiles,near_profile_count,near_page_count = NearMatchingEngine.get_near_matches(:profile=>from_profile, :mode=>:all, :result_filter=>result_filter.to_sym, :listing_type=>listing_type)
        profiles = profiles + near_profiles
        profiles.uniq!
      end
    end

    # construct the model
    profiles.each do |to_profile|
      temp_msg = ProfileMessageRecipient.find(:all,:include=>[:profile_message],:conditions=>[" profile_messages.subject = ? and profile_message_recipients.from_profile_id = ? and profile_message_recipients.to_profile_id = ? ", self.subject, from_profile.id, to_profile.id], :limit=>1)

      msg_subject = self.subject
      msg_reply_to_profile_message_id = self.reply_to_profile_message_id unless self.reply_to_profile_message_id.nil? or self.reply_to_profile_message_id.empty?

      if temp_msg.size >0
        msg = ProfileMessage.find_by_id(temp_msg[0].profile_message_id)
        msg_reply_to_profile_message_id = msg.id
        msg_subject = "Re: " + msg.subject.gsub("Re: ","")
      end
      
      msg = ProfileMessage.new
      msg.subject = msg_subject
      msg.body = self.body
      msg.reply_to_profile_message_id = msg_reply_to_profile_message_id
      
      recipient = ProfileMessageRecipient.new
      recipient.from_profile = from_profile
      recipient.to_profile = to_profile
      msg.profile_message_recipients << recipient
      message << msg
    end
    return message
  end

  def message_for_indiv?
    unless self.send_to.nil?
      if self.send_to.length == 1
        return true if self.send_to[0] == "indiv"
      else
        return true if self.send_to == "indiv"
      end
    end
  end

  def check_message_for_indiv?
    return true if (!self.send_to.nil?) and (self.send_to == "indiv")
  end

end
