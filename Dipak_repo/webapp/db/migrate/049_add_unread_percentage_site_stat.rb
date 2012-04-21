class AddUnreadPercentageSiteStat < ActiveRecord::Migration
  def self.up
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('percentage_unread_messages','Percentage of Unread Messages',now())"

    puts "Calculating historical values retroactive to Dec 21, 2007"
    now = Time.now
    (Date.new(2007,12,21)..Date.new(now.year, now.month, now.day)).each do |day|
      SiteStatManager.start_gathering_for_migration_049(day)
    end
  end

  def self.down
    execute "delete from site_stat_types where id = 'percentage_unread_messages'"
  end
end
