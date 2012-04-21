class SecondWelcomeEmailForNewUserWorker
  @queue = :second_welcome_email_for_new_user
    def self.perform
#       WelcomeEmailTwoForNewUser.send_second_welcome_email()
    end 
end