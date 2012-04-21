# edit this file to contain credentials for the OAuth services you support.
# each entry needs a corresponding token model.
#
# eg. :twitter => TwitterToken, :hour_feed => HourFeedToken etc.
#
case RAILS_ENV 
when "production"
  TWITTER_KEY = "wamwg0o4S08w4YXgU8oE9A"
  TWITTER_SECRET = "5gIXluYN69aiOD7eocWenIV3X1eSuoLHHlEhqWqVM"
when "staging"
  TWITTER_KEY = "TnG78FT5QvPyKRdhO1rU2w"
  TWITTER_SECRET = "tYTxEf1iPoVjZPhKE2MimDX6UdKP0g6Ve7RYgR6bv0"
when RAILS_ENV == "production_test"
  TWITTER_KEY = "TnG78FT5QvPyKRdhO1rU2w"
  TWITTER_SECRET = "tYTxEf1iPoVjZPhKE2MimDX6UdKP0g6Ve7RYgR6bv0"
else
  TWITTER_KEY = "TnG78FT5QvPyKRdhO1rU2w"
  TWITTER_SECRET = "tYTxEf1iPoVjZPhKE2MimDX6UdKP0g6Ve7RYgR6bv0"
end

OAUTH_CREDENTIALS={
  :twitter=>{
    :key=> TWITTER_KEY,
    :secret=> TWITTER_SECRET,
    :scope=>"http://api.twitter.com/", 
    :options => {:site => "http://api.twitter.com/", 
      :request_token_url => "http://api.twitter.com/oauth/request_token", 
      :access_token_url => "http://api.twitter.com/oauth/access_token", 
      :authorize_url=> "http://api.twitter.com/oauth/authorize"}, 
    :expose => true  
  }
  #   :google=>{
#     :key=>"",
#     :secret=>"",
#     :scope=>"" # see http://code.google.com/apis/gdata/faq.html#AuthScopes
#   },
#   :agree2=>{
#     :key=>"",
#     :secret=>""
#   },
#   :fireeagle=>{
#     :key=>"",
#     :secret=>""
#   },
#   :hour_feed=>{
#     :key=>"",
#     :secret=>"",
#     :options=>{ # OAuth::Consumer options
#       :site=>"http://hourfeed.com" # Remember to add a site for a generic OAuth site
#     }
#   },
#   :nu_bux=>{
#     :key=>"",
#     :secret=>"",
#     :super_class=>"OpenTransactToken",  # if a OAuth service follows a particular standard 
#                                         # with a token implementation you can set the superclass
#                                         # to use
#     :options=>{ # OAuth::Consumer options
#       :site=>"http://nubux.heroku.com" 
#     }
#   }
 }
# 
OAUTH_CREDENTIALS={
} unless defined? OAUTH_CREDENTIALS

load 'oauth/models/consumers/service_loader.rb'
