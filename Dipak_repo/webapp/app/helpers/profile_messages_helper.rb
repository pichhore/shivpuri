module ProfileMessagesHelper
  def style_if_new(profile_message_recipient)
    count = ProfileMessageRecipient.count_new_to_from(profile_message_recipient.to_profile_id, profile_message_recipient.from_profile_id)
    return "new" if (count > 0)
    return ""
  end
end
