# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# point it at a high, unused port for now - we don't want to send emails
#ActionMailer::Base.smtp_settings = {
#  :address => "localhost",
#  :port => 10025,
#  :domain => "localdomain.lab"
#}

 ExceptionNotifier.exception_recipients = %w(vkhandelwal@systematixtechnocrates.com ayush@systematixtechnocrates.com qasystech2@systematixtechnocrates.com kranthi.odesk@gmail.com od.amita@gmail.com)
 ExceptionNotifier.email_prefix = "[REIM-Staging] "
 ExceptionNotifier.sender_address = %("Application Error"
<vkhandelwal@systematixtechnocrates.com>)

EXCEPTION_TO = %w(vkhandelwal@systematixtechnocrates.com ayush@systematixtechnocrates.com qasystech2@systematixtechnocrates.com kranthi.odesk@gmail.com od.amita@gmail.com)
EXCEPTION_FORM = %("Application Error"
<vkhandelwal@systematixtechnocrates.com>)
EXCEPTION_EMAIL_PREFIX ="[REIM-Staging] "

