  set :stage, "production_test"
  set :scm_command, "/usr/bin/git"
  set :branch, 'staging'
  set :rails_env, "production_test"
  set :user, "deploy"
  set :runner, user
  set :admin_runner, user
  set :application, "test"   
  set :deploy_to, "/var/#{application}" 
  role :web, "67.207.151.142"
  role :app, "67.207.151.142"
  role :db,  "67.207.151.142", :primary => true
