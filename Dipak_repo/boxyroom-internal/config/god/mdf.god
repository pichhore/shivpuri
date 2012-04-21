# Mailer Daemon Fetcher
# run with: god -c /path/to/mdf.god

# Global Variables, Edit as necessary
RAILS_ROOT = "/home/boxyroom/boxyroom.com/boxyroom_web/current"
RAILS_ENV = "production"
###

  God.watch do |w|
    w.name = "mailer_daemon_fetcher"
    w.env  = { 'RAILS_ENV' => 'production' }

    # make sure you fill this in
    w.uid = "root"
#   w.gid = "davidc"

    w.interval = 30.seconds # default      
    w.start = "RAILS_ENV=#{RAILS_ENV} && #{RAILS_ROOT}/script/mailer_daemon_fetcher start"
    w.stop  = "RAILS_ENV=#{RAILS_ENV} && #{RAILS_ROOT}/script/mailer_daemon_fetcher stop"
    w.start_grace = 10.seconds
    w.restart_grace = 10.seconds
    w.pid_file = File.join(RAILS_ROOT, "log/MailerDaemonFetcherDaemon.pid")
    
    w.behavior(:clean_pid_file)

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
    
    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 150.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
      end
    
      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 5
      end
    end
    
    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
