# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
#config.action_controller.consider_all_requests_local = false

config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.action_mailer.default_url_options = { :host => "localhost", :port => "3000"}

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
# ::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
#   :login => "suppor_1268229848_biz_api1.tinkerbox.com.sg",
#   :password => "1268229853",
#   :signature => "APJsURXInCQjZy6Med47SRzi-UPQABoxmXwimxiXFIvDknRVwYYXTiM1"
# )

  Paperclip.options[:command_path] = "/opt/local/bin/"

  Geokit::Geocoders::google = 'ABQIAAAA5Yh9l21whcAUuItRzSa5ZBTJQa0g3IQ9GZqIMmInSLzwtGDKaBTfmg4s1w5pDwh3qZYkyIkEOBKnyg'
end
