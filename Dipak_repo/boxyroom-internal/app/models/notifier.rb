class Notifier < ActionMailer::Base

  # User related emails

  def activation_instructions(user)
    subject       "Activation Instruction"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    user.email
    sent_on       Time.now
    body          :account_activation_url => new_activation_url(:code => user.perishable_token), :user => user
  end

  def activation_confirmation(user)
    subject       "Activation Complete"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    user.email
    sent_on       Time.now
    content_type  "text/html"
    body          :root_url => root_url, :learn_more_url => learn_more_url, :safe_url => safe_url, :how_it_works_url => how_it_works_url, :list_a_property_url => new_property_url, :user => user
  end

  def password_reset_instructions(user)
    subject       "Password reset instructions"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  # Owner related emails

  def approved_listing_notification(property)
    subject       "Your listing has been approved"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    property.owner.email
    sent_on       Time.now
    body          :property => property, :link => property_url(property)
  end

  def rejected_listing_notification(property)
    subject       "Your listing has been rejected"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    property.owner.email
    sent_on       Time.now
    body          :property => property, :link => edit_my_property_url(property)
  end

  def new_application_notification(id)
    application = Application.find(id)
    subject       "Someone has applied for your property"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.property.owner.email
    sent_on       Time.now
    body          :application => application, :link => my_property_url(application.property), :my_dashboard_my_account_url => my_dashboard_my_account_url
  end

  def payment_made_notification(application)
    subject       "Your applicant has confirmed the rental"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.property.owner.email
    sent_on       Time.now
    body          :application => application, :link => my_property_application_url(application.property, application), :my_dashboard_my_account_url => my_dashboard_my_account_url
  end

  def refund_made_notification(application)
    subject       "Payment received has been refunded"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.property.owner.email
    sent_on       Time.now
    body          :application => application, :link => my_property_application_url(application.property, application)
  end

  # Tenant related emails

  def application_created_notification(id)
    application = Application.find(id)
    subject       "Your rental application has been forwarded to the landlord"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.user.email
    sent_on       Time.now
    body          :application => application, :my_dashboard_my_account_url => my_dashboard_my_account_url
  end

  def application_approved_notification(application)
    subject       "Your application has been approved"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.user.email
    sent_on       Time.now
    body          :application => application, :link => my_application_url(application), :my_dashboard_my_account_url => my_dashboard_my_account_url, :make_payment_my_application_url => make_payment_my_application_url(application.id)
  end

  def payment_received_notification(application)
    subject       "Your deposit has been received"
    @payment_token = application.payment_token
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.user.email
    sent_on       Time.now
    content_type     "text/html"
    body          :application => application, :link => my_application_url(application), :my_dashboard_my_account_url => my_dashboard_my_account_url
  end

  def application_rejected_notification(application)
    subject       "Your application has been declined"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.user.email
    sent_on       Time.now
    body          :application => application, :link => my_application_url(application), :root_url => root_url
  end

  def refund_received_notification(application)
    subject       "Your payment has been refunded"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.user.email
    sent_on       Time.now
    body          :application => application, :link => my_application_url(application)
  end
  
  def reject_property_documents(user,address,country)
  subject       "Your property ownership documents have been rejected"
  from          "Boxyroom <app@boxyroom.com>"
  recipients    user.email
  sent_on       Time.now
  body          :first_name => user.first_name, :unit_no => address.unit_no, :street_name => address.street_name, :postal_code => address.postal_code, :city=>address.city, :state=>address.state, :country => country.name, :link => my_properties_url
      
  end

  # forward new messages created to recipients' email

  def message(message)
    subject       message.subject
    reply_to      message.sender.email
    recipients    message.recipient.email
    sent_on       Time.now
    body          :message => message, :link => my_message_url(message.thread.code)
  end

  # process incoming emails

  def receive(mail)
    if mail['to'].to_s[0..5] != "reply_"
      return false
    end

    code = mail['to'].to_s[6..37]
    from = mail['from'].to_s
    body = mail.body[0..mail.body.index("--- Reply ABOVE THIS LINE ---")-1]

    thread = MessageThread.find_by_code(code)

    unless thread.nil?
      message = thread.messages.new do |m|
        m.subject = mail.subject
        m.body = body
        m.sent_at = mail.date
      end

      if from.include? thread.owner.email
        message.sender = thread.owner
        message.recipient = thread.participant
      elsif from.include? thread.participant.email
        message.sender = thread.participant
        message.recipient = thread.owner
      end

      message.save
      puts "One mail fetched."
    end

    true
  end
  
  # email to notify the tenant and to send the payment_token
  def payment_received_through_credit_card_notification(application)
    subject       "Your deposit has been received"
    @payment_token = application.payment_token
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.user.email
    sent_on       Time.now
    body          :application => application, :link => my_application_url(application), :my_dashboard_my_account_url => my_dashboard_my_account_url
  end
  
  def token_received_notification_to_admin(application)
    subject       "New deposit withdrawal request"
    from           "Boxyroom <app@boxyroom.com>"
    recipients   User.find(:all, :conditions =>["id IN(?)",Role.find(:all, :conditions=>[ "title=?", "admin"]).collect(&:user_id)]).collect(&:email)
    sent_on       Time.now
    content_type     "text/html"
    body             :application => application
  end
  
  def  token_received_notification_to_landlord(application)
    subject       "Your request to withdraw tenant deposit is successful"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.property.owner.email
    sent_on       Time.now
    content_type     "text/html"
    body          :application => application
  end
  
  def payment_transferred_notification_to_landlord(application)
    subject       "Your deposit has been successfully withdrawn"
    from          "Boxyroom <app@boxyroom.com>"
    recipients    application.property.owner.email
    sent_on       Time.now
    content_type     "text/html"
    body          :application => application
  end
 
end
