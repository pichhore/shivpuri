module Admin::ReportsHelper

  def set_format(record)
    record.nil? ? record : record.strftime("%m/%d/%Y %I:%M %p")
  end


  def activity_profile_name log
    if log.profile_id && log.profile.nil?
      return log.profile_name
    end

    log.seller_profile_name.blank? ?
      ( log.seller_profile.nil? ? ( log.profile.nil? ? "" : (log.profile.buyer? ? (log.profile.private_display_name.include?("Individual") ?  log.profile.display_name : log.profile.private_display_name) : log.profile.display_name)) : log.seller_profile.first_name + log.seller_profile.last_name ) : 
      log.seller_profile_name
  end


  def get_total_stick_rate
    date = 0
    free_class_id = UserClass.free_user
    users = User.find(:all, :conditions => ["is_user_cancelled_membership = ? and user_class_id = ?", true,free_class_id])
    users.each do |user|
      duration = get_duration(user)
      date = date + duration
    end
    return "%.2f" % ((date) / ((users.size)*30).to_f)
  end


  def get_individual_stick_rate(user)
    ("%.2f" % ((get_duration(user).to_f)/30))
  end

  def get_percent_of_hold_users
    cancel_users = get_total_cancel_users.to_i
    hold_users = get_hold_offer_users
    hold_users = hold_users.blank? ? 0 : hold_users.to_i
    cancel_users > 0 ? ((hold_users*100)/cancel_users) : ""
  end


  def get_total_cancel_users
    free_class_id = UserClass.free_user
    User.count(:all, :conditions => ["is_user_cancelled_membership = ? and user_class_id = ?", true,free_class_id])
  end

  def get_hold_offer_users
    free_class_id = UserClass.free_user
    User.count(:all, :conditions => ["is_user_cancelled_membership = ? and user_class_id = ? and hold_offer = ?", true,free_class_id,true])
  end

  def get_duration(user)
    (user.subscription_days > 0) ? (user.subscription_days) : (Date.parse(user.date_of_cancellation.to_s) - Date.parse(user.created_at.to_s)).to_i
  end

end
