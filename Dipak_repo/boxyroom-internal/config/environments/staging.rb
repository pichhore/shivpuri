# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

config.action_mailer.default_url_options = { :host => "50.57.64.157" }

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

Paperclip.options[:command_path] = "/usr/local/bin/"

# Geokit::Geocoders::google = 'ABQIAAAA5Yh9l21whcAUuItRzSa5ZBRsp6ZfjinTv6XJjzBLFE0vgCaLHRS6P5sbj_fb9OW8OWyyabkscHLsyA'
Geokit::Geocoders::google = 'ABQIAAAANsUyd9Aqc_t7Jvd7wHCWEhSG4Ks3gcOIJw5ou3FdfBC8RucPJRRTOeaRoBYvV9bQPv1Et4X29HNxhw'

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
  ::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
      :login => "pay_api1.boxyroom.com",
      :password => '54E5NKW6JJKDQ9CQ',
      :signature => 'AV3RMb5aIZeV9GFhUL9wzB8g5pD6AZXz67ZduFQ5RYff0KJNnPGIjEZv'
  )
end