class SellerProfile < ActiveRecord::Base

    acts_as_xapian :texts => [ :first_name, :last_name ],
       :values => [ [ :created_at, 0, "created_at", :date ] ]

  uses_guid
  belongs_to :user
  belongs_to :seller_website
  has_many :seller_property_profile, :dependent => :destroy
  has_many :profile_seller_lead_mappings, :dependent => :destroy
  validates_presence_of :first_name
#   validates_presence_of :last_name
#   validates_presence_of :phone
  validates_presence_of :email
  validates_length_of :email,    :within => 3..100, :message => 'This is invalid'
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'This is invalid'
  after_create :after_create_reward_badge

  SELLER_PROFILE_DELETE_REASON = ["bought_sold_the_property", "seller_sold_the_property", "other"]
  SELLER_PROFILE_DELETE_REASON_NAME = { "bought_sold_the_property" => "I bought/sold the property", "seller_sold_the_property" => "Seller sold property", "other" => "Other" }

    def after_create_reward_badge
      #Award a Badge to user when create seller lead
      BadgeUser.reward_badge_for_the_user(self.user)
    end

    def after_save
        seller_lead_opt_ins = SellerLeadOptIn.find(:all,:conditions=>["seller_email = ? " ,self.email])
        seller_lead_opt_ins.each do |seller_lead_opt_in|
          seller_lead_opt_in.destroy
        end
    end

  def self.count_seller_lead_in_reim(time)
    #return self.count('id', { :conditions=>["is_archive = 0 AND DATE(created_at) <= '#{time.strftime("%Y-%m-%d")}'"]})
    
    return self.count_by_sql("SELECT count(*) FROM seller_profiles, users WHERE seller_profiles.is_archive = 0 AND DATE(seller_profiles.created_at) <= '#{time.strftime("%Y-%m-%d")}' AND seller_profiles.user_id = users.id AND users.test_comp is null")

  end
  
  def self.no_of_sellers_added(user_id)
    return self.count_by_sql("select count(*) from seller_profiles where user_id='#{user_id}'")
  end

  def self.get_seller_profile_info(id)
    seller_profile = SellerProfile.find(:first, :conditions => ["id = ?",id])
    @seller_profile = seller_profile.blank? ? SellerProfile.new() : seller_profile
  end
end
