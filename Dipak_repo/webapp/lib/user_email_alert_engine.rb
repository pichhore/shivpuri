class UserEmailAlertEngine
  
  require "helpers"
  require 'tlsmail'

  def self.process(logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    user_email_alert_engine = UserEmailAlertEngine.new(logger)
    #Generate Email Alert for the Users whose activation code is not null
    user_email_alert_engine.generate_user_email_alerts()
    #Generate Email Alert For Existing User
    user_email_alert_engine.generate_email_alerts_for_existing_user()
  end

  def initialize(logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    @@now = Time.now
    @logger = logger
    @email_alert_count = 0
  end

  def self.send_welcome_email_to_user(user_id, user_login, product_id = nil)
    logger=Logger.new("#{RAILS_ROOT}/log/user_welcome_email.log")
    user = User.find_user_by_id_or_login(user_id, user_login)[0]
    logger.info " User ID: #{user_id} and User Login: #{user_login}\n"

    if product_id.blank?
      self.send_default_welcome_email(user, logger, user_id, user_login)
    else
      self.send_welcome_email_for_product(user, product_id, logger, user_id, user_login)
    end
  end
  
  def self.send_email_alert_to_existing_user(user_id, user_login, product_id)
    logger=Logger.new("#{RAILS_ROOT}/log/user_welcome_email.log")
    user = User.find_by_id(user_id)
    logger.info " User ID: #{user_id} and User Login: #{user_login}\n"
    
    email_alert_definitions = UserEmailAlertDefinition.find(:all,:conditions => ["email_type = ? and ( disabled = ? or disabled is null) and product_ids is not null and ( trigger_delay_days is null or trigger_delay_days=0 )", 'existing_welcome_reminder_email', false])

    return if email_alert_definitions.blank?

    email_alert_definitions.each do |alert_defination|
      begin
        if alert_defination.product_ids.to_s.gsub(" ", "").split(",").include?(product_id)
          logger.info " email delivered to existing user: #{user.email} \n"
          UserNotifier.deliver_user_welcome_reminder(user, alert_defination.email_subject, alert_defination.message_body)
        end
      rescue Exception => exp
        logger.info "=========== \n"
        logger.info " something went wrong \n"
        logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Error in sending welcome email")
      end
    end
  end

  def generate_user_email_alerts()
    users = User.find(:all, :conditions=> ["activation_code IS NOT NULL"])
    return if users.blank?
    @logger.info("==================================")
    @logger.info("Starting User Email Alert Engine.............")
    @logger.info("==================================")
    users.each do |user|
      products_purchased = user.lah_product_purchased_by_users.map(&:product_ids)
      if products_purchased.blank?
        generate_default_email_alert_for_new_user(user)
      else
        generate_email_alert_for_new_user_according_to_product(user, products_purchased)
      end      
    end
  end  
  
  def email_alert_exists?(user, email_alert_definition)
    exists = user.email_alert_to_users.any? { |email_alert| email_alert.user_email_alert_definition == email_alert_definition }
    @logger.debug("Already exists") if exists and @logger.debug?
    return exists
  end

  def add_email_alert(user, email_alert_definition)
    @logger.debug("<b style='color:green'>Adding</b> user email alert [#{email_alert_definition.title}] for user <b>[#{user.login}]</b>") if @logger.debug?
    user_email_alert = EmailAlertToUser.new
    user_email_alert.event_time = @@now
    user_email_alert.user_email_alert_definition = email_alert_definition
    user_email_alert.user = user
    user_email_alert.save!
    @email_alert_count += 1
  end

  def generate_email_alerts_for_existing_user()
    email_alert_definitions = UserEmailAlertDefinition.find(:all,:conditions => ["email_type = ? and product_ids is not null and trigger_delay_days > 0", 'existing_welcome_reminder_email'])
    return if email_alert_definitions.blank?

    lah_users = LahProductPurchasedByUser.find(:all, :joins => :user, :conditions => ["users.activation_code is null"])

    return if lah_users.blank?
    @logger.info("==================================")
    @logger.info("Starting Email Alert Engine For Existing User")
    @logger.info("==================================")
    lah_users.each do |lah_user|
      user = lah_user.user
      next if user.blank?
      next unless user.activated?
      email_alert_definitions.each do |email_alert_definition|
        begin
          product_ids = email_alert_definition.product_ids.to_s.gsub(" ", "").split(",")
          next unless product_ids.include?(lah_user.product_ids)
          
          date_created = lah_user.created_at.to_date + email_alert_definition.trigger_delay_days.to_i
          next unless date_created.strftime("%m/%d/%y") == Date.today.strftime("%m/%d/%y")

            @logger.debug("")
            @logger.debug("Checking alert <b>[#{email_alert_definition.title}]</b> for user <b>[#{user.login}]</b>") if @logger.debug?
            if(email_alert_definition.disabled == false or email_alert_definition.disabled.nil?)
              add_email_alert(user, email_alert_definition) if !email_alert_exists?(user, email_alert_definition)
            else
              @logger.debug("Alert found but <b style='color:red'>disabled</b>, hence alert not added to user_email_alerts table")
            end
        rescue Exception=>exp
          BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"UserEmailAlertEngine")
          @logger.info("Could not start Email Alert Engine for this User Id:: #{user.id}")
        end
      end
    end
    @logger.info("")
    @logger.info("Added #{@email_alert_count} email alerts") 
  end

private
  
  def generate_default_email_alert_for_new_user(user)
    email_alert_definitions = UserEmailAlertDefinition.find(:all,:conditions => ["email_type = ? and ( product_ids is null or product_ids = ? ) and trigger_delay_days > 0", 'welcome_reminder', ''])
    
    return if email_alert_definitions.blank?

    email_alert_definitions.each do |email_alert_definition|
      begin
        create_alert_for_user(email_alert_definition, user)
      rescue Exception=>exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"UserEmailAlertEngine")
        @logger.info("Could not start Email Alert Engine for this User Id:: #{user.id}")
      end
    end
  end
  
  def generate_email_alert_for_new_user_according_to_product(user, products_purchased)
    email_alert_definitions = UserEmailAlertDefinition.find(:all,:conditions => ["email_type = ? and product_ids is not null and trigger_delay_days > 0", 'welcome_reminder'])

    email_alert_definitions.each do |email_alert_definition|
      begin
      
        products_purchased.each do |product_id|
          if email_alert_definition.product_ids.to_s.gsub(" ", "").split(",").include?(product_id)
            create_alert_for_user(email_alert_definition, user)
            @flag_alert_created = true
          end
        end
      rescue Exception=>exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"UserEmailAlertEngine")
        @logger.info("Could not start Email Alert Engine for this User Id:: #{user.id}")
      end
    end
    generate_default_email_alert_for_new_user(user) unless @flag_alert_created
  end  

  def create_alert_for_user(email_alert_definition, user)
    trigger_date_parameter = email_alert_definition.trigger_parameter_value.blank? ? user.created_at : user[email_alert_definition.trigger_parameter_value.to_s]
    date_created = trigger_date_parameter.to_date + email_alert_definition.trigger_delay_days.to_i

    return unless date_created.strftime("%m/%d/%y") == Date.today.strftime("%m/%d/%y")

    @logger.debug("")
    @logger.debug("Checking alert <b>[#{email_alert_definition.title}]</b> for user <b>[#{user.login}]</b>") if @logger.debug?
    
    if(email_alert_definition.disabled == false or email_alert_definition.disabled.nil?)
      add_email_alert(user, email_alert_definition) if !email_alert_exists?(user, email_alert_definition)
    else
      @logger.debug("Alert found but <b style='color:red'>disabled</b>, hence alert not added to user_email_alerts table")
    end
  end

  def self.send_welcome_email_for_product(user, product_id, logger, user_id, user_login)
    email_alert_definitions = UserEmailAlertDefinition.find(:all,:conditions => ["email_type = ? and ( disabled = ? or disabled is null) and product_ids is not null and ( trigger_delay_days is null or trigger_delay_days = 0 )", 'welcome_reminder', false])

    email_alert_definitions.each do |alert_defination|
      begin
        if alert_defination.product_ids.to_s.gsub(" ", "").split(",").include?(product_id)
          logger.info " email delivered to: #{user.email} \n"
          UserNotifier.deliver_user_welcome_reminder(user, alert_defination.email_subject, alert_defination.message_body)
          @welcome_email_flag = true
          UserTransactionHistory.create(:user_id => user.id, :transanction_detail => "Welcome email sent to customer")
        end
      rescue Exception => exp
        logger.info "=========== \n"
        logger.info " something went wrong \n"
        logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Error in sending welcome email")
      end
    end
    send_default_welcome_email(user, logger, user_id, user_login) unless @welcome_email_flag
  end

  def self.send_default_welcome_email(user, logger, user_id, user_login)
    alert_defination = UserEmailAlertDefinition.find(:first,:conditions => ["email_type = ? and ( disabled = ? or disabled is null) and ( product_ids is null or product_ids = ? ) and ( trigger_delay_days is null or trigger_delay_days=0 )", 'welcome_reminder', false, ''])
    return if alert_defination.blank?

    user = User.find_user_by_id_or_login(user_id, user_login)[0] if user.blank?

    begin
      logger.info " email delivered to: #{user.email} \n"
      UserNotifier.deliver_user_welcome_reminder(user, alert_defination.email_subject, alert_defination.message_body)
      UserTransactionHistory.create(:user_id => user.id, :transanction_detail => "Welcome email sent to customer")
    rescue Exception => exp
      logger.info "=========== \n"
      logger.info " something went wrong \n"
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Error in sending welcome email")
    end
  end
end
