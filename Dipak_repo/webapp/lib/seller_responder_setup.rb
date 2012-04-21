class SellerResponderSetup

  SELLER_RESPONDER_SEQUENCE_EMAIL_NUMBER = { "sequence_one" => { 0 => 1},"sequence_two" => {0 => 1, 2 => 2, 4 => 3, 6 => 4, 30 => 5, 60 => 6, 90 => 7, 120 => 8, 150 => 9, 180 => 10, 210 => 11, 240 => 12, 270 => 13, 300 => 14,  330 => 15, 360 => 16}, "sequence_three" => {0 => 1, 2 => 2, 15 => 3, 30 => 4, 60 => 5, 90 => 6, 120 => 7, 150 => 8, 180 => 9, 210 => 10, 240 => 11, 270 => 12, 300 => 13,  330 => 14, 360 => 15}, "sequence_four" => {0 => 1, 4 => 2, 15 => 3, 30 => 4, 60 => 5, 90 => 6, 120 => 7, 150 => 8, 180 => 9, 210 => 10, 240 => 11, 270 => 12, 300 => 13,  330 => 14, 360 => 15}}

  SEND_MAIL_FOR_SEQUENCE_ARRAY = { "sequence_one" => [0], "sequence_two" => [0, 2, 4, 6, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360], "sequence_three" => [0, 2, 15, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360], "sequence_four" => [0, 4, 15, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360]}

  SELLER_REPONDER_SEQUENCE_NAME = ["sequence_one", "sequence_two", "sequence_three", "sequence_four"]

  def self.send_message
    @logger = Logger.new("#{RAILS_ROOT}/log/seller_responder_sequence.log")
    responder_sequence_for_sellers = ResponderSequenceAssignToSellerProfile.all
    return if responder_sequence_for_sellers.blank?
    for responder_sequence_for_seller in responder_sequence_for_sellers
      begin
        next unless responder_sequence_for_seller.seller_responder_sequence.active
        next unless SELLER_REPONDER_SEQUENCE_NAME.include?(responder_sequence_for_seller.seller_responder_sequence.sequence_name.to_s)
        next unless responder_sequence_for_seller.seller_property_profile.responder_sequence_subscription

        responder_sequence_for_seller.update_attributes(:mail_number => responder_sequence_for_seller.mail_number.to_i + 1) if send_mail_to_seller(responder_sequence_for_seller,responder_sequence_for_seller.seller_responder_sequence, responder_sequence_for_seller.mail_number.to_i)
      rescue Exception=>exp
        @logger.info "SellerResponderSetup error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"SellerResponderSetup")
      end
    end
  end

private

  def self.send_mail_to_seller(responder_sequence_for_seller,seller_responder_sequence, seller_mail_number)
    notification_email =  SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_responder_sequence,SELLER_RESPONDER_SEQUENCE_EMAIL_NUMBER[seller_responder_sequence.sequence_name][seller_mail_number],seller_responder_sequence.sequence_name)

    if SEND_MAIL_FOR_SEQUENCE_ARRAY[seller_responder_sequence.sequence_name].include?(seller_mail_number)
      seller_property_profile = responder_sequence_for_seller.seller_property_profile
      UserNotifier.deliver_send_seller_responder_sequence_notification(notification_email, seller_property_profile.seller_profile, seller_property_profile)

      engagement_note = seller_property_profile.seller_engagement_infos.create(:subject => notification_email.email_subject, :description => notification_email.email_body, :note_type => "Email" )

      @logger.info "Send mail to Seller for #{seller_responder_sequence.sequence_name}: -----First Name: #{responder_sequence_for_seller.seller_property_profile.seller_profile.first_name} - Seller Email: #{responder_sequence_for_seller.seller_property_profile.seller_profile.email} \n"
    end
    true
  end
end