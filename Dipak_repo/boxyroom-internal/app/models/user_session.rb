class UserSession < Authlogic::Session::Base
  validate :generic_error
  def generic_error
	  RAILS_DEFAULT_LOGGER.debug "checking errors ..."
	  email_v = false
	  email_b = false
	  pass_v = false
	  pass_b  = false
	  errors.each do |attr,message|
		  puts "Error: #{attr.inspect}: #{message}"
		  if  (attr == 'email' and message == 'is not valid') 
			  email_v = true
		  end
		  if (attr == 'email' and message == "cannot be blank") 
			  email_b = true
		  end
		  if (attr == 'password' and message == "is not valid") 
			  pass_v = true
		  end
		  if (attr == 'password' and message == "cannot be blank") 
			  pass_b = true
		  end
	  end
	  RAILS_DEFAULT_LOGGER.debug "clearing errors ..."
	  errors.clear
	  errors.add_to_base("Your email address doesn't look correct.") if email_v
	  errors.add_to_base("Enter your email.") if email_b
	  errors.add_to_base("Your password is not correct.") if pass_v
	  errors.add_to_base("Enter your password.") if pass_b
  end
end

