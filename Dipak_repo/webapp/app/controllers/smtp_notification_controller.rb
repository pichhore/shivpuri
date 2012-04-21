class SmtpNotificationController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def index
     smtp_notification_logfile = File.open("#{RAILS_ROOT}/log/smtp_notification.log", 'a')
      smtp_notification_logfile.sync = true
      smtp_notification_logger = SmtpNotificationLogger.new(smtp_notification_logfile)
      smtp_notification_logger.debug params.to_yaml
    if request.post? 
      begin
         smtp_notification = SmtpNotification.create(:event=>params[:event] , :email=>params[:email] , :category=>params[:category], :status=>params[:status],:reason=>params[:reason],:attempt=>params[:attempt],:type=>params[:type],:url=>params[:url],:response=>params[:response])
     rescue Exception=>exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      end
    end
    render :text=>"ok" and return
  end
end
