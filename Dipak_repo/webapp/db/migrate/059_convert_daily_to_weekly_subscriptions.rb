class ConvertDailyToWeeklySubscriptions < ActiveRecord::Migration
  def self.up
    # Remove Daily email subscriptions and convert them to weekly, per the new subscription spec
    execute "UPDATE users set digest_frequency = 'W' where digest_frequency = 'D'"

    puts "\n\n**** REMEMBER: Remove the daily crontab entry, as daily digests are no longer supported!!!!\n\n"
  end

  def self.down
    # nothing to undo, as it cannot be reversed
  end
end
