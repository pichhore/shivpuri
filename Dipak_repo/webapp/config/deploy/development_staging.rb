 set :stage, "development_staging"
 set :scm_command, "/usr/local/bin/git"
 set :branch, 'staging'
 set :rails_env, "staging"
 set :user, "deploy"
 set :runner, user
 set :admin_runner, user
 set :application, "test"
 set :deploy_to, "/var/apps/rei_production_test/rei_staging/#{application}"
 set :ruby_path, "/home/deploy/.rvm/rubies/ruby-1.8.7-p249"
 set :gem_path, "/home/deploy/.rvm/rubies/ruby-1.8.7-p249/lib/ruby/gems/1.8"
 role :web, "208.78.97.33"
 role :app, "208.78.97.33"
 role :db,  "208.78.97.33", :primary => true

