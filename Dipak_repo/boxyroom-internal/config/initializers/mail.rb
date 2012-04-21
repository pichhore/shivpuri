ActionMailer::Base.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "gmail.com",
    :authentication => :plain,
    :user_name => "app@boxyroom.com",
    :password => "boxyroom123"
  }