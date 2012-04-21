class UserObserver < ActiveRecord::Observer
  def after_create(user)
    begin
      user_activation_code = user.activation_code
      unless user.activation_code.blank?
        user.activation_code = nil
        user.save
      end
      UserForumIntegration.create_user_on_forum(user.login,user.password,user.email) if RAILS_ENV == "production"
      Icontact.add_contact_from_userobj(user, user.password, true) unless ICONTACT_HTTP_HEADER.blank?
    rescue
    end
    user_pass = user.password

#    Resque.enqueue(UserWelcomeNotificationWorker,user.email,user.first_name,user.login,user_activation_code,user.id,user_pass)
    Resque.enqueue(UserWelcomeNotificationWorker,user.id, user.login, user.lah_product_id, false)
#    UserEmailAlertEngine.send_welcome_email_to_user(user.id, user.lah_product_id)
  end
  
  def after_save(user)
    alertDefinitions = AlertDefinition.find(:all, :conditions=>["disabled is null or disabled = ?", false])
    alert_engine = AlertEngine.new
    alertDefinitions.each do |alert_definition|
      count_alerts = Alert.find(:all,:conditions=>[" user_id = ? and  alert_definition_id = ?", user.id, alert_definition.id ])
      unless count_alerts.size == 1
        alert_engine.add_alert(user, alert_definition) if ! alert_engine.alert_exists?(user, alert_definition) and alert_engine.alert_triggered?(user, alert_definition)
      end
    end
    if user.recently_activated? && user.is_infusionsoft == false
      # Sending activation email through background process 
      Resque.enqueue(UserActivationNotificationWorker,user.id)
    end
  end
end
