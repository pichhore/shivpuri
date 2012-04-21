require 'tlsmail'
namespace :db do
  desc 'Send welcome reminder emails to the user those who are not login their account with in a time period.  Set RAILS_ENV to override.'
	task :process_user_emails => :environment do   
          logger=Logger.new("#{RAILS_ROOT}/log/process_user_email_alert.log")
          logger.info " process user emails: #{Date.today} \n"
          EmailAlertToUser.find(:all, :conditions => ["date(event_time) LIKE ?", Date.today]).each do |alert|
          begin 
            alert_defination = alert.user_email_alert_definition
       	    if alert_defination.email_type == "welcome_reminder"
              reminder_user = alert.user
              logger.info " email delivered to: #{reminder_user.email} \n"
              hdr = UserNotifier.getsendgrid_header(reminder_user)
              #UserNotifier.deliver_user_welcome_reminder(reminder_user.email, alert_defination.subject, alert_defination.message_body, hdr.asJSON())
              UserNotifier.deliver_user_welcome_reminder(reminder_user, alert_defination.email_subject, alert_defination.message_body)
            end
            rescue Exception => exp
              BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"process_email_rake_file")
            end
          end    
        end
end
