class SiteStatManager

  def self.start_gathering(time=Time.now, remove_stats_from_today=true)
    site_stats_manager = SiteStatManager.new(time)
    site_stats_manager.remove_stats_from_today if remove_stats_from_today
    site_stats_manager.gather
  end

  def self.start_gathering_for_migration_049(time=Time.now, remove_stats_from_today=true)
    site_stats_manager = SiteStatManager.new(time)
    site_stats_manager.remove_stats_from_today if remove_stats_from_today
    site_stats_manager.gather_for_migration_049
  end

  def initialize(time)
    @time = time
  end

  def remove_stats_from_today
    SiteStat.delete_all("stats_date = '#{@time.strftime("%Y-%m-%d")}'")
  end

  def gather
    self.methods.select {|method_name| method_name[0,5] == "calc_" }.each do |method_name|
      begin
        self.send method_name.to_sym
      rescue Exception=>exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"SiteStatManager")
      end
    end
  end

  def gather_for_migration_049
    self.methods.select {|method_name| method_name[0,5] == "calc_" }.each do |method_name|
      begin
        self.send method_name.to_sym unless method_name == "calc_total_message_recipients"
      rescue Exception=>exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"SiteStatManager")
      end
    end
  end

  #
  # Calc methods
  #
  # NOTE: any of the helper methods called with (@time) must do a date check of anything < (but not <=) the date, since
  # the stat gathering happens in the early morning hours, prior to site activity. See User.count_active_users(@time)
  # as an example
  #

  def calc_active_accounts
    create_and_save_stat('total_active_accounts', User.count_active_users(@time))
  end

  def calc_active_buyers
    create_and_save_stat('total_active_buyer_profiles', Profile.count_active_buyers(@time))
  end

  def calc_active_owners
    create_and_save_stat('total_active_owner_profiles', Profile.count_active_owners(@time))
  end

  def calc_active_owners_public
    create_and_save_stat('total_active_owners_public', Profile.count_active_owners_public(@time))
  end

  def calc_active_owners_private
    create_and_save_stat('total_active_owners_private', Profile.count_active_owners_private(@time))
  end

  def calc_sent_messages
    create_and_save_stat('total_sent_messages', ProfileMessage.count_messages(@time))
  end

  def calc_total_message_recipients
    create_and_save_stat('total_message_recipients', ProfileMessageRecipient.count_sent_messages(@time))
  end

  def calc_total_logins_daily
    create_and_save_stat('total_logins_daily', ActivityLog.count_logins_for(@time))
  end

  def calc_total_digest_daily_freq
    create_and_save_stat('total_digest_daily', User.count_digest_daily(@time))
  end

  def calc_total_digest_weekly_freq
    create_and_save_stat('total_digest_weekly', User.count_digest_weekly(@time))
  end

  def calc_total_digest_monthly_freq
    create_and_save_stat('total_digest_monthly', User.count_digest_monthly(@time))
  end

  def calc_percentage_unread_messages
    create_and_save_stat('percentage_unread_messages', ProfileMessageRecipient.calc_percentage_unread(@time))
  end

  def calc_pro_subscription_users
    create_and_save_stat('pro_subscription_users', User.count_pro_subscription_users(@time))
  end

  def calc_plus_subscription_users
    create_and_save_stat('plus_subscription_users', User.count_plus_subscription_users(@time))
  end

  def calc_free_subscription_users
    create_and_save_stat('free_subscription_users', User.count_free_subscription_users(@time))
  end

  def calc_failed_payment_users
    create_and_save_stat('failed_payment_users', User.count_failed_payment_users(@time))
  end

  def calc_seller_lead_in_reim
    create_and_save_stat('seller_lead_in_reim', SellerProfile.count_seller_lead_in_reim(@time))
  end

  #
  # Helpers
  #

  def create_and_save_stat(type_id, value_num, user_id=nil, profile_id=nil)
    site_stat = SiteStat.create!({ :site_stat_type_id => type_id, :value_num => value_num, :user_id=>user_id, :profile_id=>profile_id, :stats_date=> @time})
    return site_stat
  end

end
