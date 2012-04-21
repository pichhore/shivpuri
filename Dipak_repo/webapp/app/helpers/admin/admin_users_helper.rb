module Admin::AdminUsersHelper

  def salt_column(record)
    link_to("Change", :action => :change_password, :controller => '/admin/admin_users', :id => record.id)
  end

  def created_at_column(record)
    record.created_at.nil? ? record.created_at : record.created_at.strftime("%m/%d/%Y %I:%M %p")
  end 
  
  def updated_at_column(record)
    record.updated_at.nil? ? record.updated_at : record.updated_at.strftime("%m/%d/%Y %I:%M %p")
  end

  def activated_at_column(record)
    record.activated_at.nil? ? record.activated_at : record.activated_at.strftime("%m/%d/%Y %I:%M %p")
  end

  def last_login_at_column(record)
    record.last_login_at.nil? ? record.last_login_at : record.last_login_at.strftime("%m/%d/%Y %I:%M %p")
  end

  def find_checked(badge_id, user_badges)
    badge_array = Array.new
    user_badges.each do |user_badge|
      badge_array << user_badge.badge_id
    end
    return true if badge_array.include?(badge_id)
  end

  def failed_payment_date_for_user
    return @user.failed_payment_date.blank? ? "" : @user.failed_payment_date.to_date.strftime("%m/%d/%y")
  end
end
