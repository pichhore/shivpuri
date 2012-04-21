  set :stage, "production"
  set :scm_command, "/usr/bin/git"
  set :branch, 'production'
  set :rails_env, "production"
  set :user, "deploy"
  set :runner, user
  set :admin_runner, user
  set :application, "reimatcher"
  set :deploy_to, "/var/www/apps/#{application}"
  set :ruby_path, "/usr"
  set :gem_path, "/usr"
  role :web, "67.207.151.142"
  role :app, "67.207.151.142"
  role :db,  "67.207.151.142", :primary => true

