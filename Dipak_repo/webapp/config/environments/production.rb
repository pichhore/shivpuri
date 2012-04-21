# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# log rotation support from http://snippets.dzone.com/posts/show/979
config.logger = Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log", 50, 10.megabytes)

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
config.action_controller.asset_host                  = "http://assets.reimatcher.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.raise_delivery_errors = true

#ActionMailer::Base.delivery_method = :sendmail
#ActionMailer::Base.smtp_settings = {
 # :address => 'localhost',
  #:domain => '',
 #:port => 25
#}


