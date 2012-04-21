set :stage, "staging"
server '50.57.64.157', :app, :web, :db
set :deploy_path, "/home/staging_boxyroom"
set :repository, "git@bitbucket.org:amaheshwari/boxyroom-internal"
set :deploy_to, "#{deploy_path}"

namespace :mongrel do
  desc "Restart Application"
  task :restart, :roles => [:web, :db, :app] do
    puts "restart staging app"
    run "/usr/local/rvm/rubies/ruby-1.8.7-p334/bin/ruby /usr/local/rvm/gems/ruby-1.8.7-p334/bin/mongrel_rails stop -c /home/staging_boxyroom/current -p 5000 -P tmp/pids/mongrel.5000.pid"
    run "/usr/local/rvm/rubies/ruby-1.8.7-p334/bin/ruby /usr/local/rvm/gems/ruby-1.8.7-p334/bin/mongrel_rails stop   -c /home/staging_boxyroom/current -p 5001 -P tmp/pids/mongrel.5001.pid"
    run "/usr/local/rvm/rubies/ruby-1.8.7-p334/bin/ruby /usr/local/rvm/gems/ruby-1.8.7-p334/bin/mongrel_rails start -d -e staging -a 127.0.0.1 -c /home/staging_boxyroom/current -p 5000 -P tmp/pids/mongrel.5000.pid -l log/mongrel.5000.log"
    run "/usr/local/rvm/rubies/ruby-1.8.7-p334/bin/ruby /usr/local/rvm/gems/ruby-1.8.7-p334/bin/mongrel_rails start -d -e staging -a 127.0.0.1 -c /home/staging_boxyroom/current -p 5001 -P tmp/pids/mongrel.5001.pid -l log/mongrel.5001.log"
  end
end