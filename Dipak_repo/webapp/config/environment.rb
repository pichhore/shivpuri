unless '1.9'.respond_to?(:force_encoding)
  String.class_eval do
    begin
      remove_method :chars
    rescue NameError
      # OK
    end
  end
end
  
# Be sure to restart your web server when you modify this file.
  
# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'
  
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
  
# lock to specific version of validatable gem (for Mike)
#gem 'validatable', '= 1.6.4'
# require the Class extension
require File.join(File.dirname(__FILE__), '../extensions/class')
require File.join(File.dirname(__FILE__), '../extensions/object')
  
# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
  
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]
  config.frameworks -= [ :action_web_service ]
  
  # loading workers for resque / resque-schedular
  config.load_paths << "#{RAILS_ROOT}/app/workers"
  
  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :profile_observer, :profile_image_observer
  
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  config.time_zone = "Central Time (US & Canada)"
  
  config.gem 'permalink'
  config.gem 'geoip'
  config.gem 'tlsmail'
  config.gem 'httparty'
  config.gem 'feedtools', :lib => 'feed_tools'
  config.gem 'validatable'
  config.gem "oauth"
  config.gem "oauth-plugin"
  config.gem "twitter"
  config.gem "oauth2", :version => "<= 0.4.1"
  config.gem "facebook_oauth"
  config.gem "bitly"
  config.gem "mime-types", :lib => "mime/types"
  config.gem "pdfkit", :version => "0.4.6"
  config.gem "wkhtmltopdf-binary"

  # See Rails::Configuration for more options
 end

REIM_WP_SECRETE_KEY = "reimwpkeyvers000"
REIMATCHER_URL = "http://www.reimatcher.com/" if RAILS_ENV == "production"
REIMATCHER_URL = "http://stage.reimatcher.com/" if RAILS_ENV == "staging"
REIMATCHER_URL = "http://localhost:3000/" if RAILS_ENV == "development"
REIMATCHER_URL = "test.local" if RAILS_ENV == "test"
REIMATCHER_URL = "http://dev.reimatcher.com/" if RAILS_ENV == "production_test"

case RAILS_ENV 
when "production"
  BITLY_UID = "reimatcher"
  BITLY_API_KEY = "R_ffbcebafedc958fa5b5d8d5b02d5a928"
when "staging"
  BITLY_UID = "o_7v7gbvrq5q"
  BITLY_API_KEY = "R_664fedaf2a3c2ccd162422414b872066"
when RAILS_ENV == "production_test"
  BITLY_UID = "o_7v7gbvrq5q"
  BITLY_API_KEY = "R_664fedaf2a3c2ccd162422414b872066"
else
  BITLY_UID = "o_7v7gbvrq5q"
  BITLY_API_KEY = "R_664fedaf2a3c2ccd162422414b872066"
end

REI_404_PAGE = "#{RAILS_ROOT}/public/404.html"
  
SYNDICATION_URL = "http://www.resynd.com/"  if RAILS_ENV == "production"

SYNDICATION_URL = "http://stage.resynd.com/" if RAILS_ENV == "development" || RAILS_ENV == "staging" || RAILS_ENV == "production_test"
# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
  
# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
  
# Include your application configuration below
ActiveRecord::Base.record_timestamps = true
ActiveRecord::Base.default_timezone = :utc
  
# require the class extensions
require File.join(File.dirname(__FILE__), '../extensions/array')
require File.join(File.dirname(__FILE__), '../extensions/acts_as_paranoid')
  
# globally require these

require 'permalink'
require 'feed_tools'
require 'geoip'
require 'tlsmail'

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "fieldWithErrors"
  if html_tag =~ /<(input|textarea|select)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class} ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class='#{error_class}' "
  end
  html_tag
end

BASIC_USER_CLASS = { :basic_type => "UC0", :uc1_type => "UC1", :uc2_type => "UC2" }

  if (RAILS_ENV == "production" or RAILS_ENV == "staging")

    #~ Net::SMTP.enable_tls( OpenSSL::SSL::VERIFY_NONE )
    ActionMailer::Base.smtp_settings = {
          :enable_starttls_auto => true,
          :address => 'smtp.sendgrid.net',
          :port => 25,
          :domain => 'reimatcher.com',
          :authentication => :plain,
          :user_name => 'sendgrid@reimatcher.com',
          :password => '4sendgridpwd',
      }

  end
   
  ICONTACT_HTTP_HEADER = Hash.new()

  if RAILS_ENV == "production"
    ICONTACT_HTTP_HEADER = {
      :accept_type => "application/json",
      :content_type => "application/json",
      :api_version => "2.2",
      :api_app_id => "VV8Qz8fvNP9tG0w4U3bhFilILAXNEhYq",
      :api_user_name => "damonflowers",
      :api_password => "stpl2010",
      :accountid => "839779",
      :clientfolderid => "3518",
      :uc1_list_id => "8624",
      :canceled_user_list_id => "34985",
      :free_user_list_id => "45198",
      :new_uc2_list_id => "53440",
      :uc2_list_id => "53439",
      :your_sites_done_for_you => "55171"
      }
     NGINX_CONF_FILE_PATH = "/etc/nginx/site_enable/prod_seller_websites.config"
     NGINX_BUYER_CONF_FILE_PATH = "/etc/nginx/site_enable/prod_buyer_websites.config"
     NGINX_INVESTOR_CONF_FILE_PATH = "/etc/nginx/site_enable/prod_investor_websites.config"
     NGINX_SM_CONF_FILE_PATH = "/etc/nginx/site_enable/prod_seller_magnets.config"
  end


  if RAILS_ENV == "staging"
    ICONTACT_HTTP_HEADER = {
      :accept_type => "application/json",
      :content_type => "application/json",
      :api_version => "2.2",
      :api_app_id => "BzJA3xkqKg0jsMoHqaUlTl3mGxBF8CiA",
      :api_user_name => "vkhandelwal",
      :api_password => "st$l2010",
      :accountid => "905999",
      :clientfolderid => "18268",
      :uc1_list_id => "28315",
      :canceled_user_list_id => "28314",
      :free_user_list_id => "38308",
      :new_uc2_list_id => "26472",
      :uc2_list_id => "30626",
      :your_sites_done_for_you => "44459"
      }
    NGINX_CONF_FILE_PATH = "/etc/nginx/site_enable/stage_seller_websites.config"
    NGINX_BUYER_CONF_FILE_PATH = "/etc/nginx/site_enable/stage_buyer_websites.config"
    NGINX_INVESTOR_CONF_FILE_PATH = "/etc/nginx/site_enable/stage_investor_websites.config"
    NGINX_SM_CONF_FILE_PATH = "/etc/nginx/site_enable/stage_seller_magnets.config"
  end
  
#For Development Server
  if RAILS_ENV == "production_test"
    NGINX_CONF_FILE_PATH = "/etc/nginx/site_enable/dev_seller_websites.config"
    NGINX_BUYER_CONF_FILE_PATH = "/etc/nginx/site_enable/dev_buyer_websites.config"
    NGINX_INVESTOR_CONF_FILE_PATH = "/etc/nginx/site_enable/dev_investor_websites.config"
    NGINX_SM_CONF_FILE_PATH = "/etc/nginx/site_enable/dev_seller_magnets.config"
  end

  if RAILS_ENV == "development"
    ExceptionNotifier.exception_recipients = %w() #insert your email id to recieve development's Application Error email e.g. vkhandelwal@systematixtechnocrates.com
    ExceptionNotifier.email_prefix = "[REIM-Development] "
    EXCEPTION_TO = %w( )#insert your email id to recieve development's Application Error email e.g. vkhandelwal@systematixtechnocrates.com
    EXCEPTION_EMAIL_PREFIX ="[REIM-Development] "
    
    #Need to be given values before testing it on local for making domain name entry dynamically on Nginx
    NGINX_CONF_FILE_PATH = "/etc/nginx/site_enable/dev_seller_websites.config"
    NGINX_BUYER_CONF_FILE_PATH = "/etc/nginx/site_enable/dev_buyer_websites.config"
    
  else
    ExceptionNotifier.exception_recipients = %w(dev-alerts@reimatcher.com)
    ExceptionNotifier.email_prefix = "[REIM-Production] "
    EXCEPTION_TO = %w(dev-alerts@reimatcher.com)
     EXCEPTION_EMAIL_PREFIX ="[REIM-Production] "
  end
  
   ExceptionNotifier.sender_address = %("Application Error"
   <noreply@reimatcher.com>)
  EXCEPTION_FORM = %("Application Error"
   <noreply@reimatcher.com>)

SYND_APP = YAML.load_file("#{RAILS_ROOT}/config/syndicator_auth_credentials.yml")

