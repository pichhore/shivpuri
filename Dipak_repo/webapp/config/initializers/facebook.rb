case RAILS_ENV 
when "production"
  FB_KEY = "260922190617742"
  FB_SECRET = "8c923302054b7ee2f7f77fd7538ad8db"
when "staging"
  FB_KEY = "168580773229515"
  FB_SECRET = "604ce3cd7bbf93189d6556f941fb11bb" 
when RAILS_ENV == "production_test"
  FB_KEY = "300854953273252"
  FB_SECRET = "33cbc4d1c01fdb06ee123f92bdebd3fe"
else
  FB_KEY = "302004296482184"
  FB_SECRET = "3200e5a58b0a57a021c18f31642ea426" 
end

FACEBOOK = {
  :key=> FB_KEY,
  :secret=> FB_SECRET,
  :scope=>"http://facebook.com/", 
  :options => {:site => "https://graph.facebook.com",  
    :request_token_url => "http://www.facebook.com/dialog/oauth", 
    :access_token_url => "https://graph.facebook.com/oauth/access_token",
    :authorize_url=> "https://graph.facebook.com/oauth/authorize"}, 
  :expose => true  
}
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

