class AddNewTotalSentMessagesSiteStat < ActiveRecord::Migration
  def self.up
    execute "INSERT into site_stat_types (id, name, created_at) VALUES ('total_message_recipients','Total Messages Sent to All Recipients',now())"
    execute "UPDATE site_stat_types set name = 'Total Unique Messages Sent' where id = 'total_sent_messages'"

    # Step 1 - need to update all stats for 'total_sent_messages' to ensure the proper values jive with the historical values
    # Step 2 - create new entries for the new 'total_message_recipients' stat to get the historical values

    # 1. delete old stats
    SiteStat.delete_all("site_stat_type_id = 'total_sent_messages' and stats_date >= '2008-02-08'")

    # 2. ask the manager to create new stats for us
    now = Time.now
    (Date.new(2008,2,8)..Date.new(now.year, now.month, now.day)).each do |day|
      manager = SiteStatManager.new(day)
      manager.calc_sent_messages
    end

    (Date.new(2007,12,21)..Date.new(now.year, now.month, now.day)).each do |day|
      manager = SiteStatManager.new(day)
      manager.calc_total_message_recipients
    end

  end

  def self.down
    # not going to revert
  end
end
