class BackgroundJobExceptionNotifier < ActionMailer::Base
  def background_exception_notification(exp,class_name)
    @from = EXCEPTION_FORM
    @recipients = EXCEPTION_TO
    @subject =  "#{EXCEPTION_EMAIL_PREFIX}#{class_name}# (#{exp.class}) #{exp.message.inspect}"
    @sent_on = Time.now
    @body[:exception] = exp
    @body[:class_name] = class_name
    @content_type = "text/html"
    end
end
