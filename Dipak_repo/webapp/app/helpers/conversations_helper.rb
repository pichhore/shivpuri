module ConversationsHelper

  # prevent going to the DB for every to/from in the recipient table by doing a check of the two
  # profiles instances known to be involved in the conversation
  def extract_profile_from(profile_id)
    return @profile if profile_id == @profile.id
    return @target_profile
  end

  def sent_received_from(from_profile)
    return "Sent from me" if from_profile.id == @profile.id
    return "Received from #{from_profile.display_name}"
  end

  def build_reply_subject(subject)
    return "#{subject}" if subject[0,3] == "Re:"
    return "Re: #{subject}"
  end

  def style_if_new(conversation_message_recipient)
    return "new" if (@marked_as_new and @marked_as_new.include?(conversation_message_recipient))
    return ""
  end
end
