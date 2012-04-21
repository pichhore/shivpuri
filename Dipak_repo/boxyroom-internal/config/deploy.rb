require 'mongrel_cluster/recipes'
set :stages, %w(production staging)
require 'capistrano/ext/multistage'
set :ssh_options, {:forward_agent => true}
set :user, 'root'
default_run_options[:pty] = true
set :scm, "git"
set :branch, "master"
set :use_sudo, false
#set :deploy_via, :remote_cache

namespace :deploy do

  task :restart, :roles => :app, :except => { :no_release => true } do
    if stage == 'production'
      passenger.restart
    end
    if stage == 'staging'
      mongrel.restart
    end
  end

  after "deploy:update_code", :roles => [:web, :db, :app] do
    if stage == 'production'
      run "rake -f #{current_path}/Rakefile gems:install RAILS_ENV=production"
      # darkness ensues, for god has left us.
      run "god terminate"
      puts "did it work?"
    end
  end

  after "deploy:symlink", :roles => [:web, :db, :app] do
    if stage == 'production'
      run "cp #{deploy_path}/shared/database.yml #{deploy_path}/current/config/database.yml"
      run "cp #{deploy_path}/shared/restart.txt #{deploy_path}/current/tmp/restart.txt"
      run "chown -R boxyroom:apache #{deploy_path}/current/"
      # and god said, let there be light!
      run "god -c #{current_path}/config/god/god.conf -l #{current_path}/log/god.log"
    end
    if stage == 'staging'
      run "ln -nfs #{deploy_path}/shared/config/database.yml #{release_path}/config/database.yml"
    end
  end

  task :after_deploy do
    cleanup
    puts "#####################################################################################"
    puts "--------------------------#{stage} deployment done-----------------------------------"
    puts "#####################################################################################"
  end
end
