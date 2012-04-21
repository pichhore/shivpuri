class SellerMagnetResponder

  AMPS_MAGNET_RESPONDERS = ['amps_cold', 'amps_new']
  
  RESPONDERS_SCHEDULE = {
    "amps_cold" => [0, 30, 60, 90, 120, 150],
    "amps_new" => [0]
  }

  def self.process
    @mail_counter = 0
    @report = String.new
    @logger = Logger.new("#{RAILS_ROOT}/log/seller_magnet_sequence.log")

    ResponderSequenceAssignToSellerProfile.find_in_batches(:conditions =>["seller_responder_sequences.sequence_name IN (?) AND seller_responder_sequences.active = ?", AMPS_MAGNET_RESPONDERS, true], :joins => :seller_responder_sequence, :batch_size => 10, :readonly => false) do |responders|
      for responder in responders
        begin
          # next unless responder.seller_property_profile.responder_sequence_subscription
          process_responder_email(responder)
          responder.update_attribute('mail_number', responder.mail_number.to_i + 1)
        rescue Exception=>exp
          @logger.info "SellerMagnetResponder Error : (#{exp.class}) #{exp.message.inspect} "
          BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"SellerResponderSetup")
        end
      end
    end

    # send_seller_magnet_report
  end

  def self.process_responder_email responder
    seller_sequence = responder.seller_responder_sequence
    sequence_name = seller_sequence.sequence_name
    schedule_match = RESPONDERS_SCHEDULE[seller_sequence.sequence_name].index(responder.mail_number.to_i)

    if !schedule_match.nil?
      responder_email = SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_sequence, schedule_match+1, sequence_name)
      seller_property_profile = responder.seller_property_profile
      seller_profile = seller_property_profile.seller_profile

      UserNotifier.deliver_send_seller_responder_sequence_notification(responder_email, seller_profile, seller_property_profile)
      engagement_note = seller_property_profile.seller_engagement_infos.create(:subject => responder_email.email_subject, :description => responder_email.email_body, :note_type => "Email" )
      site_url = seller_sequence.user.seller_magnet.blank? ? nil : seller_sequence.user.seller_magnet.site_url
      
      log_string = "Squence Name:#{seller_sequence.sequence_name}, Mail Subject:#{responder_email.email_subject}, Seller Magnet:#{site_url}, Seller Name: #{seller_profile.first_name}, Seller Email: #{seller_profile.email}<br/>"
      @logger.info log_string 
      @report += log_string
      @mail_counter += 1
    end
  end

  # def self.send_seller_magnet_report
    # UserNotifier.deliver_amps_magnet_responder_report(@mail_counter, @report)
  # end
end
