#~ require '../config/environment.rb'

# class TestResponderSetup
# 
#   REIMATCHER_URL = "http://www.reimatcher.com" if RAILS_ENV == "production"
#   REIMATCHER_URL = "http://208.78.97.33:89" if RAILS_ENV == "staging"
# 
#   def self.send_message
#   
#     user_terriotries= UserTerritory.find(:all)
#       
#        for territory in user_terriotries
# 	        if !territory.user.buyer_notification.blank? 
# 	            active_inactive = territory.user.buyer_notification.find(:first,:conditions=>["summary_type LIKE ?",'trust_resp_series'])
# 		    if !active_inactive.blank? && active_inactive.trust_responder_series == true
# 			   if !territory.squeeze_page_opt_in.blank?
# 				   #need to ask aush on this
# 				#~ for squeeze_page_opt in territory.squeeze_page_opt_in
# 					#~ puts "Responder#need to askmail#{squeeze_page_opt.mail_number}"
# 					#~ squeeze_page_opt.update_attibute(:mail_number,squeeze_page_opt.mail_number+1)
# 				#~ end
# 				puts territory.squeeze_page_opt_in.mail_number
# 				territory.squeeze_page_opt_in.update_attributes(:mail_number=>territory.squeeze_page_opt_in.mail_number+1)
# 			   end
# 		    end
# 	       end
# 	
#        end
# end
# 
# end
# 
# 
# TestResponderSetup.send_message
class TrustResponderSetup
  #sending Trust Responder email to retail buyer.
  def self.send_message
    @logger = Logger.new("#{RAILS_ROOT}/log/trust_responder.log")
    user_terriotries= UserTerritory.find_all_user_terrirory_for_trust_res_mail
    return if user_terriotries.blank?
    for territory in user_terriotries
      begin
        send_mail_to_squeze_buyers territory
        send_mail_to_retail_buyers territory
      rescue Exception=>exp
        @logger.info " TrustResponderSetup error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"TrustResponderSetup")
      end
    end
  end

private

  def self.send_mail_to_squeze_buyers (territory)
    buyer_from_squeeze = territory.squeeze_page_opt_ins
    return if buyer_from_squeeze.blank?
    user_buyer_notification = BuyerNotification.get_buyer_notification_for_trust_responder(territory.user.id , BuyerNotification::SUMMARY_TYPE['trust_resp_series'])
    return if user_buyer_notification.nil?
    for buyer in buyer_from_squeeze
      begin
        if buyer.trust_responder_subscription
          is_squeeze_buyer = true 
          if send_mail_to_buyer(buyer.retail_buyer_first_name,buyer.retail_buyer_email,buyer.mail_number,territory.user, user_buyer_notification,buyer.id,is_squeeze_buyer)
            buyer.update_attributes(:mail_number=>buyer.mail_number+1)
            @logger.info " send_mail_to_buyer on squeeze_page_opt_ins : to -first name #{buyer.retail_buyer_first_name} - retail_buyer_email #{buyer.retail_buyer_email} : at #{Time.now} : from #{territory.user.full_name } <#{territory.user.investor_email_address}>"
          end
        end
      rescue Exception=>exp
        @logger.info " TrustResponderSetup error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"TrustResponderSetup")
      end
    end
  end 

  def self.send_mail_to_retail_buyers (territory)
    buyer_from_retail_buyer = territory.retail_buyer_profiles
    return if buyer_from_retail_buyer.blank?
    user_buyer_notification = BuyerNotification.get_buyer_notification_for_trust_responder(territory.user.id , BuyerNotification::SUMMARY_TYPE['trust_resp_series'])
    return if user_buyer_notification.nil?
    for buyer in buyer_from_retail_buyer
      begin
        if buyer.trust_responder_subscription
          next if (( buyer.profile.blank? ) or ( buyer.profile.display_notification_email.blank? ) )
          buyer_email = buyer.profile.display_notification_email
          is_squeeze_buyer = false
          if send_mail_to_buyer(buyer.first_name,buyer_email,buyer.mail_number,territory.user, user_buyer_notification,buyer.profile_id,is_squeeze_buyer)
            buyer.update_attributes(:mail_number=>buyer.mail_number+1)
            # buyer.profile.buyer_engagement_infos.create(:subject => user_buyer_notification.subject, :description => "#{user_buyer_notification.email_intro}"+"#{user_buyer_notification.email_closing}", :note_type => "Email" )
            @logger.info " send_mail_to_buyer on retail_buyer_profiles : to -first name #{buyer.first_name} - retail_buyer_email #{buyer_email} : at #{Time.now} : from #{territory.user.full_name } <#{territory.user.investor_email_address}>"
          end
        end
      rescue Exception=>exp
        @logger.info " TrustResponderSetup error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"TrustResponderSetup")
      end
    end
  end

  def self.send_mail_to_buyer(buyer_first_name,buyer_email,buyer_mail_number,investor,user_buyer_notification,buyer_id,is_squeeze_buyer)
    return false unless buyer_mail_number < 13
    trust_responder = fetch_trust_responder_email_body(user_buyer_notification, "trust_responder_email" + ((buyer_mail_number/2) + 1 ).to_s)

    UserNotifier.deliver_trust_responder_notification(buyer_first_name,buyer_email,buyer_mail_number,investor,trust_responder,buyer_id,is_squeeze_buyer) if [0, 2, 4, 6, 8, 10, 12].include?(buyer_mail_number)
    true
  end

  def self.fetch_trust_responder_email_body(user_buyer_notification, trust_responder_type)
    trust_responder_notification = TrustResponderMailSeries.get_trust_responder_notification(user_buyer_notification, trust_responder_type)
    return trust_responder_notification
  end
end
