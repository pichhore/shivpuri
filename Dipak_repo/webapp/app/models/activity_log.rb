class ActivityLog < ActiveRecord::Base
  uses_guid
  belongs_to :activity_category

  def self.count_logins_for(time)
    #return self.count('id', :conditions=>["DATE(created_at) = ?", time.strftime("%Y-%m-%d")])
    return self.count_by_sql("SELECT count(*) FROM activity_logs, users WHERE DATE(activity_logs.created_at) = '#{time.strftime("%Y-%m-%d")}' AND activity_logs.user_id = users.id AND users.test_comp is null")
  end

  def self.find_recent(start_date_string, end_date_string)
    return ActivityLog.find(:all, :conditions=>["DATE(created_at) <= ? AND DATE(created_at) >= ?", end_date_string, start_date_string], :order=>"created_at DESC", :include=>:activity_category)
  end

  def profile
    Profile.find_profile_by_id_only(profile_id) if profile_id
  end
  
  def seller_profile
    SellerProfile.find(seller_profile_id) if seller_profile_id
  end

  def user
    User.find_by_id(user_id) if user_id
  end
end
