class MapLahProductWithUser < ActiveRecord::Base

  belongs_to :user
  before_save :assign_membership_at_wp_instance

protected

  def assign_membership_at_wp_instance
    old_access_for_wp = MapLahProductWithUser.find_by_id(self.id)
    user = self.user
    return if user.blank?
    return if old_access_for_wp.blank?
    product_name = ""
    product_name = "mrmm" if !self.rei_mkt_dept and old_access_for_wp.rei_mkt_dept != self.rei_mkt_dept
    product_name = "allinone" if !self.allinone and old_access_for_wp.allinone != self.allinone
    UserForumIntegration.remove_membersip_for_user_from_wordpress_instance(user.login, user.email, product_name) if RAILS_ENV == "production" and !product_name.blank?
  end

end
