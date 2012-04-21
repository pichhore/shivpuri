class BadgeUser < ActiveRecord::Base
  validates_uniqueness_of :badge_id, :scope => :user_id
  belongs_to :badge
  belongs_to :user
 

  def self.reward_badge_for_the_user(user)
    begin
      user_badge_ids = BadgeUser.find_all_by_user_id(user.id).map(&:badge_id)
      buyer_count = Profile.count_active_buyers_for_particular_user(user.id)
      property_count = Profile.count_active_owners_for_particular_user(user.id)
      properties_sold = Profile.count_sold_property_for_particular_user(user.id)
      deal_completed = Profile.no_of_deals_completed(user.id)
      investor_message_sent = InvestorMessage.no_of_investor_messages_sent(user.id)
      seller_added = SellerProfile.no_of_sellers_added(user.id)

      badges = Badge.get_badges_whose_certification_is_null
      badges.each do |badge|
        unless user_badge_ids.include?(badge.id)
          if badge.profiles_added.to_i <= buyer_count.to_i and badge.properties_added.to_i <= property_count.to_i and badge.properties_sold.to_i <= properties_sold.to_i and badge.sellers_added.to_i <= seller_added.to_i and badge.deals_completed.to_i <= deal_completed.to_i and badge.investor_messages_sent.to_i <= investor_message_sent.to_i and badge.certification.blank?
            time_span = !badge.membership_time.nil? ? "#{badge.membership_time}.month" : ""
            createdate = !time_span.blank? ? ((user.created_at + eval(time_span)) <= Time.now ? true : false ) : true
            if createdate
              badge_user = BadgeUser.create(:user_id => user.id, :badge_id => badge.id)
              self.email_notification_to_user_for_badge(badge_user)
            end
          end
        end
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Badges")
    end
  end
  
  def self.email_notification_to_user_for_badge(badge_user)
   user_email = badge_user.user.email
   name = badge_user.user.first_name
   badge = badge_user.badge
   image = badge_user.badge.badge_image
#   Resque.enqueue(SendNotificationForNewBadgeWorker,user_email, name, badge.name, image, badge.email_subject, badge.email_body, badge.email_header, badge.email_footer)
   UserNotifier.deliver_send_notification_for_new_badge(user_email, name, badge.name, image, badge.email_subject, badge.email_body, badge.email_header, badge.email_footer)
  end
  
  def self.assign_membership_time_badge_to_user
    badges = Badge.find(:all, :conditions=>["membership_time is not null"])
    badges.each do |badge|
      users = User.find(:all,:conditions=>["created_at>=?",Time.now - eval("#{badge.membership_time.to_i}.month")])
      users.each do |user|
        user_badge_ids = BadgeUser.find_all_by_user_id(user.id).map(&:badge_id)
        buyer_count = Profile.count_active_buyers_for_particular_user(user.id)
        property_count = Profile.count_active_owners_for_particular_user(user.id)
        properties_sold = Profile.count_sold_property_for_particular_user(user.id)
        unless user_badge_ids.include?(badge.id)
          if badge.profiles_added.to_i <= buyer_count.to_i and badge.properties_added.to_i <= property_count.to_i and badge.properties_sold.to_i <= properties_sold.to_i
            badge_user = BadgeUser.create(:user_id => user.id, :badge_id => badge.id)
            self.email_notification_to_user_for_badge(badge_user)
          end
        end
      end
    end
  end
  
  def self.process_users_to_assign_badges
    begin
      batch_size = 100
      users = User.count(:all)
      i = (users.to_f/batch_size).ceil
      return if i == 0
      (1..i).each do |index|
        offset = batch_size*(index-1)
        Resque.enqueue(AssignBadgesToUsersWorker,batch_size,offset)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Badges")
    end
  end
  
  def self.assign_badges_to_users(limit,offset)
    begin
      users = User.find(:all, :limit => limit, :offset => offset)
      users.each do |user|
        self.reward_badge_for_the_user(user)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Badges")
    end
  end
end
