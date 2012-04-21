class EmailAlertToUser < ActiveRecord::Base
  uses_guid
  belongs_to :user_email_alert_definition
  belongs_to :user

  def self.process_user_emails
    logger=Logger.new("#{RAILS_ROOT}/log/process_user_email_alert.log")
    logger.info " process user emails: #{Date.today} \n"
    EmailAlertToUser.find(:all, :conditions => ["date(event_time) LIKE ?", Date.today]).each do |alert|
      begin 
        alert_defination = alert.user_email_alert_definition
        
        reminder_user = alert.user
        logger.info " email delivered to: #{reminder_user.email} \n"
        hdr = UserNotifier.getsendgrid_header(reminder_user)
        UserNotifier.deliver_user_welcome_reminder(reminder_user, alert_defination.email_subject, alert_defination.message_body)
        
      rescue Exception => exp
        logger.info " something went wrong \n"
        logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"process_email_rake_file")
      end
    end
  end

end
