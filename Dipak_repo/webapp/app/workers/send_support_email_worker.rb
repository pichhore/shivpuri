class SendSupportEmailWorker
  @queue = :send_support_email

  def self.perform(to_email, subject, body, email, first_name, last_name)
    UserNotifier.deliver_send_support_email(to_email, subject, body, email, first_name, last_name)
  end 
end
