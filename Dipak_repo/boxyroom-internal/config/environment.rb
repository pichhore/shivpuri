# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
# require 'thread'

require File.join(File.dirname(__FILE__), 'boot')

if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.3.7')
 module Rails
   class GemDependency
     def requirement
       r = super
       (r == Gem::Requirement.default) ? nil : r
     end
   end
 end
end

Rails::Initializer.run do |config|
  config.gem "geokit"
  config.gem "activemerchant", :lib => "active_merchant"
  config.gem "authlogic", :version => "~> 2"
  config.gem "searchlogic"
  config.gem "aasm"
  config.gem "mislav-will_paginate", :version => "~> 2.3.11", :lib => "will_paginate", :source => "http://gems.github.com"
  config.gem "declarative_authorization", :source => "http://gemcutter.org"
 # config.gem "paperclip", :source => "http://gemcutter.org"
  config.gem "crummy", :source => "http://gemcutter.org"
  config.gem "SystemTimer", :version => "1.1.3", :lib => "system_timer"
  config.gem "validates_timeliness", :version => "~> 2.3"
  config.gem "god"
  config.gem "exceptional", :version => "2.0.6"
#   config.gem "rmagick","2.31.1"
  config.gem 'currencies', :require => 'iso4217'
  config.active_record.observers = :user_observer, :property_observer, :application_observer, :message_thread_observer, :message_observer
  config.gem 'tzinfo'
  config.gem 'geoip'
  config.gem 'geonames'

  config.time_zone = 'UTC'
end

ExceptionNotification::Notifier.sender_address =   %("Application Error" <app@boxyroom.com>)
ExceptionNotification::Notifier.exception_recipients = %w(msaraf@systematixtechnocrates.com)

BOXYROOM_ADMIN_FEE = 0.1
PAYMENT_TO_LANDLRD = 0.9
CURRENCIES ={"SGD" => "S", "USD" => "US", "AUD" => "A", "CAD" =>"C", "NZD" => "NZ", "MXN" => "Mex", "HKD" => "HK"}
 Paperclip.options[:command_path] = "/usr/bin"