require 'resque'
require 'resque_scheduler'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]
Resque.schedule = YAML.load_file(File.join(File.dirname(__FILE__), '../resque_schedule.yml'))

AUTH_PASSWORD = "rei$ab3jI"
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
      password == AUTH_PASSWORD
  end
end
