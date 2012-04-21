module SellerResponderSystemHelper
  # builds responder links dynamically
  def display_sequence_for_series(sequence_name)
    responder_links = ""
    SellerResponderEmailTemplate.const_get(sequence_name.upcase+"_EMAIL_SUBJECT").size.times{|i|
      responder_links += display_email_links(i+1,sequence_name)
    }
    return responder_links
  end

  def responder_sequences
    [ ["sequence_one", "New Lead", "Thank You email is sent to the Seller lead immediately after they complete an opt-in or lead capture form on your Seller Website"], ["sequence_two", "Trying to Reach You", "Responder sequence to be initiated when Investor has attempted to phone Seller lead several times with no response"], ["sequence_three", "After Call: Next Steps", "Responder sequence to be initiated when Investor has submitted proposal or contract and is following up with Seller lead on next steps"],["sequence_four", "After Call: Not Now", "Responder sequence to be initiated when Seller lead has said they are not ready to move forward and/or need more time"],["amps_cold", "AMPS Cold Lead", "AMPS Cold Leads are sellers who completed the initial opt-in on the AMPS Seller Magnet Page only. These seller leads are still looking at their options and may or may not be interested in talking further"],["amps_new", "AMPS Hot Lead", "AMPS Hot Leads are sellers who completed opt-ins on both the AMPS Seller Magnet and Results Page. These seller leads have submitted their information to you and are expecting a follow-up phone call or email"]]
  end
  
  def display_email_links(email_number,sequence_name)
    email_name = (["sequence_one", "amps_new"].include?(sequence_name) ? "Thank You" : "Email" + email_number.to_s)
    return "<a href='/seller_responder_system/seller_responder_sequence_series?email_number=#{email_number}&sequence_name=#{sequence_name}' style=#{(params[:sequence_name] == sequence_name && params[:email_number].to_i == email_number.to_i) ? 'font-weight:bold' : ''}>#{email_name}</a><br>"
  end
  
  def display_email_description(email_description)
    return User.display_email_assign_values(current_user, email_description.to_s)
  end
end
