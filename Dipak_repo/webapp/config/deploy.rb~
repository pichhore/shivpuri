# MODIFY THE FILE ACCORDING TO THE COMMENTS BEFORE DEPLOYMENT
require 'mongrel_cluster/recipes'
set :default_stage, "development"
set :stages, %w(production production_test development development_staging)
require 'capistrano/ext/multistage'

set :migrate_target, :current
set :use_sudo,false

set :scm, :git
set :local_scm_command, "/usr/bin/git" #SET THIS AS YOUR LOCAL GIT BINARY PATH
set :repository, "git@reimatcher.unfuddle.com:reimatcher/reim-redux.git"
set :database, "mysql"
default_run_options[:shell]= false
set :keep_releases, 3

 namespace :deploy do 
   # Mongrel + capistriano
    task :restart, :roles => :app do 
    if stage == 'production'
       run <<-EOF
	    #{gem_path}/bin/mongrel_cluster_ctl stop 

	  EOF
    elsif stage == 'production_test'
       run <<-EOF
            cd #{release_path} && #{gem_path}/bin/mongrel_rails stop -P #{shared_path}/log/mongrel.pid
        EOF
      run <<-EOF
            #{ruby_path}/bin/ruby #{gem_path}/bin/mongrel_rails start -d -e production_test -a 127.0.0.1 -c /var/test/current -p 3000
        EOF
    elsif stage == 'development_staging'
       run <<-EOF
            cd #{release_path} && #{gem_path}/bin/mongrel_rails stop -P #{shared_path}/log/mongrel.3000.pid
        EOF
    elsif stage == 'development'
       run <<-EOF
            cd #{release_path} && #{gem_path}/bin/mongrel_rails stop -P #{shared_path}/log/mongrel.3001.pid
        EOF
    end
  end

    task :production_test_stop, :roles => :app do 
      if stage == 'production_test'
       run <<-EOF
            cd #{current_path} && #{gem_path}/bin/mongrel_rails stop -P #{shared_path}/log/mongrel.pid
        EOF
      end
    end

    task :production_test_start, :roles => :app do 
      if stage == 'production_test'
      run <<-EOF
            #{ruby_path}/bin/ruby #{gem_path}/bin/mongrel_rails start -d -e production_test -a 127.0.0.1 -c /var/test/current -p 3000
        EOF
      end
    end
  
    task :development_staging_stop, :roles => :app do 
      if stage == 'development_staging'
       run <<-EOF
            cd #{current_path} && #{gem_path}/bin/mongrel_rails stop -P #{shared_path}/log/mongrel.3000.pid
        EOF
      end
    end

    task :development_staging_remove_mongrel_pid, :roles => :app do 
      if stage == 'development_staging'
       run <<-EOF
            cd #{current_path}/log && rm -f mongrel.3000.pid
        EOF
      end
    end

    task :development_staging_start, :roles => :app do 
      if stage == 'development_staging'
      run <<-EOF
            #{ruby_path}/bin/ruby #{gem_path}/bin/mongrel_rails start -d -e staging -a 127.0.0.1 -c /var/apps/rei_production_test/rei_staging/test/current -p 3000
        EOF
      end
    end


    task :development_stop, :roles => :app do 
      if stage == 'development'
       run <<-EOF
	    #{ruby_path}/bin/ruby #{gem_path}/bin/mongrel_cluster_ctl stop
        EOF
      end
    end

    task :development_start, :roles => :app do 
      if stage == 'development'
      run <<-EOF
	    #{gem_path}/bin/mongrel_cluster_ctl start
        EOF
      end
    end


    desc "Create all symlinks "
    task :create_symlinks, :roles => :app do
          run <<-CMD
	     ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml
          CMD
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/profile_images #{release_path}/public/profile_images
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/investor_website_images #{release_path}/public/investor_website_images
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/ads #{release_path}/public/images/ads
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/sitemap.xml #{release_path}/public/sitemap.xml
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/geoip #{release_path}/db/geoip
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/geoip #{release_path}/public/geoip
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/buyer_user_images #{release_path}/public/buyer_user_images
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/user_company_images #{release_path}/public/user_company_images
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/badge_images #{release_path}/public/badge_images
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/testimonial_pictures #{release_path}/public/testimonial_pictures
	  EOF
          run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/public/xapian_db #{release_path}/public
	  EOF
  end

 desc " production newrelic symlink"
  task :symlink_new_relic , :roles => :app do
      if stage == 'production'
        run <<-EOF
              ln -nfs #{deploy_to}/#{shared_dir}/config/newrelic.yml #{release_path}/config/newrelic.yml
            EOF
        run <<-EOF
              ln -nfs #{deploy_to}/#{shared_dir}/plugins/newrelic_rpm #{release_path}/vendor/plugins/newrelic_rpm
            EOF
      end
  end
   
   desc "Updating xapian "
   task :update_xapian do
        run <<-EOF
             cd #{release_path} && RAILS_ENV=#{rails_env} #{gem_path}/bin/rake xapian:update_index models="Profile User SellerProfile SellerPropertyProfile RetailBuyerProfile ProfileFieldEngineIndex"
  	    EOF
   end

  desc "Database Backup "
   task :db_backup do
      if stage == 'production'
        run <<-EOF
	      /home/deploy/db_backup.sh
	    EOF
      end
   end

  desc "Create EVP symlinks "
   task :evp_symlinks do
      if stage == 'production'
        run <<-EOF
             cd #{shared_path} && ln -nsf #{shared_path}/admin #{release_path}/public/admin
          EOF
      end
   end
  
  desc "Move app dir contents to release dir"
   task :move_app do
        run "rm -rf #{release_path}/public"
        run <<-EOF
              mv -f #{release_path}/webapp/* #{release_path}
          EOF
        run "rm -rf #{release_path}/webapp/"
        stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
        asset_paths = %w(images stylesheets javascripts).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
        run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
   end
  
  desc "Stop Resque workers"
   task :stop_resque_workers do
        if stage == 'production' || stage == 'development_staging'
          run "cd #{current_path} && #{gem_path}/bin/rake queue:stop_workers RAILS_ENV=#{rails_env}"
        end
   end
  
  desc "Stop Resque Scheduler"
   task :stop_resque_scheduler do
        if stage == 'development_staging'
          run "ps -ef | grep resque\:scheduler | head -n 1 | awk '{print $2}' | xargs kill -9"
          run "ps -ef | grep resque\:scheduler | head -n 1 | awk '{print $2}' | xargs kill -9"
        elsif stage == 'production'
          run "sh /home/deploy/resque_sched.sh"
        end
   end

  desc "Restart resque-web"
   task :restart_resque_web do
        if stage == 'production' || stage == 'development_staging'
          run "#{gem_path}/bin/resque-web -K"
          run "cd #{current_path} && #{gem_path}/bin/resque-web config/initializers/resque.rb"
        end
   end
 
  desc "Run Migration"
   task :migrate do
           run  <<-EOF
             cd #{release_path} && RAILS_ENV=#{rails_env} #{gem_path}/bin/rake db:migrate
           EOF
   end
  
  desc "Install Gems"
   task :install_gems do
           run  <<-EOF
             cd #{release_path} && RAILS_ENV=#{rails_env} #{gem_path}/bin/rake gems:install
           EOF
   end

  desc "Loading Missing Zips"
   task :load_missing_zips do
           run  <<-EOF
             cd #{release_path} && RAILS_ENV=#{rails_env} #{gem_path}/bin/rake db:load_zip_codes
           EOF
   end

  after 'deploy:update_code', 'deploy:move_app'
  after 'deploy:move_app', 'deploy:create_symlinks'
  after 'deploy:create_symlinks', 'deploy:evp_symlinks'
  after 'deploy:evp_symlinks', 'deploy:symlink_new_relic'
  after 'deploy:symlink_new_relic', 'deploy:install_gems'
  after 'deploy:install_gems', 'deploy:migrate'
  after 'deploy:migrate', 'deploy:load_missing_zips'
  after 'deploy:load_missing_zips', 'deploy:update_xapian'
  after 'deploy:update_xapian', 'deploy:db_backup'
  after 'deploy:db_backup', 'deploy:stop_resque_scheduler'
  after 'deploy:stop_resque_scheduler', 'deploy:stop_resque_workers'
end
