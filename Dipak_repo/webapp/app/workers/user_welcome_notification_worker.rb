class UserWelcomeNotificationWorker
  @queue = :user_welcome_notification
  
  def self.perform(user_id, user_login, product_id, is_existing_user_purchase_product)
    if is_existing_user_purchase_product
      UserEmailAlertEngine.send_email_alert_to_existing_user(user_id, user_login, product_id)
    else
      UserEmailAlertEngine.send_welcome_email_to_user(user_id, user_login, product_id)
    end
  end
#    def self.perform(email,first_name,login,activation_code,user_id,user_pass)
#      user_password = user_pass
#       user = User.find_by_id (user_id)
#        hdr = UserNotifier.getsendgrid_welcome_header(email,first_name)
#        UserNotifier.deliver_welcome(email,first_name,login,activation_code,user_password,hdr.asJSON())
#        UserTransactionHistory.create(:user_id => user_id, :transanction_detail => "Welcome email sent to customer")
#    end
end
