set :stage, "production"
set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
server 'boxyroom.com', :app, :web, :db
set :deploy_path, "/home/boxyroom/boxyroom.com/boxyroom_web"
set :repository, "git@tinkerbox.unfuddle.com:tinkerbox/boxyroom.git"
set :deploy_to, "#{deploy_path}"

namespace :passenger do
  desc "Restart Application"
  task :restart, :roles => [:web, :db, :app] do
    run "touch #{current_path}/tmp/restart.txt"
  end
end