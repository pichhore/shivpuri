# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every 1.day, :at => '12:00 am' do
    command "/script/dwellgo/gather_stats.sh"
end  

every 1.day, :at => '11:00 am' do
    command "/script/dwellgo/digest_daily.sh"
end

every 1.day, :at => '12:05 am' do
    runner "BuyerProfileNotification.send_daily_notification_to_buyer()"
end
  
every :thursday, :at => '11:00 am' do
    runner "BuyerProfileNotification.send_weekly_notification_to_buyer()"
  end
  
every 1.day, :at => '10:00 am' do
    runner "EmailAlertEngine.process()"
  end
  
every 1.day, :at => '11:00 am' do
    rake "db:process_emails"
end

every 1.day, :at => '10:00 am' do
    runner "Profile.destroy_profile_by_cron()"
  end

every 1.day, :at => '11:00 am' do
    runner "TrustResponderSetup.send_message()"
end

every 5.minutes do
    rake "xapian:update_index models=Profile"
end
  
every 30.minutes do
  command "/script/dwellgo/clicktale_tracking.sh"
end
