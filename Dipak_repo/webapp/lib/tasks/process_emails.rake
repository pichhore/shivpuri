require 'tlsmail'
namespace :db do
  desc 'Send mails to the property or buyer profiles those who are about to expire.  Set RAILS_ENV to override.'
	task :process_emails => :environment do   
      EmailAlert.find(:all, :conditions => ["date(event_time) LIKE ?", Date.today]).each do |alert|
        begin 
	if EmailAlertDefinition.find(alert.email_alert_definition_id).email_type == "property_profile"
          user = User.find(alert.user_id)
          profile_find_by_profile_id = Profile.find_by_id(alert.profile)
          next if profile_find_by_profile_id.blank?
          recipient_email = user.email
          recipient_first_name = user.first_name
          subject = EmailAlertDefinition.find(alert.email_alert_definition_id).email_subject
          message = EmailAlertDefinition.find(alert.email_alert_definition_id).message_body
          address = ProfileField.find(:first, :conditions => ["profile_id LIKE ? AND `key` LIKE ?","#{alert.profile}", 'property_address']).value
          pfei_find_by_profile_id = ProfileFieldEngineIndex.find_by_profile_id(alert.profile)
          next if pfei_find_by_profile_id.blank?
          zip_code = pfei_find_by_profile_id.zip_code
          zipcode = Zip.find(:first, :conditions => ["zip LIKE ?", zip_code])
          #if RAILS_ENV=="development"
          #  profile_link = "http://localhost:3000/profiles/#{alert.profile}/edit?dgb=1"
          #else
            profile_link = "#{REIMATCHER_URL}profiles/#{alert.profile}/edit?dgb=1"
          #end
          #send_mail(recipient_email, recipient_first_name, subject, message, profile_link,address,zip_code,zipcode)
            hdr = UserNotifier.getsendgrid_header(user)
          UserNotifier.deliver_property_expired(recipient_email, recipient_first_name, subject, message, profile_link,address,zip_code,zipcode,hdr.asJSON())
        end
	if EmailAlertDefinition.find(alert.email_alert_definition_id).email_type == "buyer_profile"
          user = User.find(alert.user_id)
          recipient_email = user.email
          recipient_first_name = user.first_name
          subject = EmailAlertDefinition.find(alert.email_alert_definition_id).email_subject
          message = EmailAlertDefinition.find(alert.email_alert_definition_id).message_body
	  pfei_array = ProfileFieldEngineIndex.find(:all, :conditions => {:profile_id => alert.profile})
	  zip_code_array = []
	  pfei_array.each do |pfei|
	  zip_code_array << pfei.zip_code
      	  end
	  pfei_data = pfei_array.first
	  profile = Profile.find_by_id(alert.profile)
	  unless profile.blank?
	  retail_buyer_profile = profile.retail_buyer_profile
	  profile_fields_data = profile.profile_fields
	  else
	  retail_buyer_profile = nil
	  end
          name = ""
          if !profile.nil?
            name = profile.buyer? ? (profile.private_display_name.include?("Individual") ?  profile.display_name : profile.private_display_name) : profile.display_name
          end
   	  zip_code_string = zip_code_array.join(',')
          #if RAILS_ENV=="development"
          #  profile_link = "http://localhost:3000/profiles/#{alert.profile}/edit?dgb=1"
          #else
            profile_link = "#{REIMATCHER_URL}profiles/#{alert.profile}/edit?dgb=1"
          #end
          #send_mail(recipient_email, recipient_first_name, subject, message, profile_link,address,zip_code,zipcode)
            hdr = UserNotifier.getsendgrid_header(user)
          UserNotifier.deliver_buyer_expired(recipient_email, recipient_first_name, subject, message, profile_link,name,zip_code_string,retail_buyer_profile,pfei_data,profile_fields_data, hdr.asJSON())
        end

        rescue Exception => exp
           BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"process_email_rake_file")
        end
      end    
  end
  
  def send_mail(recipient_email,recipient_first_name, subject, message, profile_link,address,zip_code,zipcode)
    string = <<EOF
From:  <no-reply@reimatcher.com>
To: #{recipient_first_name} <#{recipient_email}>
Subject: #{subject}
Date: #{Time.now.rfc2822}
content-type: text/html

  
  #{message.to_s.gsub("[Property Profile Link]",profile_link).gsub("[Property Profile Address]",address).gsub("[Zip Code]",zip_code).gsub("[State]",zipcode.state).gsub("[City]",zipcode.city)}
  <br /><br />
EOF


    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start("smtp.gmail.com", "587", "gmail.com", "reimatcheradmn", "password4321", :plain) do |smtp|
      smtp.send_message string, "noreply@reimatcher.com", recipient_email
      logger = Logger.new('emails_log.log');
      logger.info("Mail sent to #{recipient_first_name} <#{recipient_email}> at #{Time.now}");
    end
  end
end
