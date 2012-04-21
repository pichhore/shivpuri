class UserTerritory < ActiveRecord::Base
  uses_guid
  belongs_to :territory
  belongs_to :user
  has_one :buyer_web_page, :dependent => :destroy
  has_many :squeeze_page_opt_ins, :dependent => :destroy
  has_many :retail_buyer_profiles , :dependent => :nullify

  validates_uniqueness_of :territory_id ,:scope=>:user_id
  validates_presence_of :territory_id
  validates_presence_of :user_id ,:message=>"User can't be blank"
#have to set anather validation three territory for each user 

  named_scope :find_all_user_terrirory_for_trust_res_mail, :include=>[:user , :squeeze_page_opt_ins, :retail_buyer_profiles]

  def reim_name
    territory.reim_name
  end

  def has_active_buyer_site?
    return false if buyer_web_page.nil? || !buyer_web_page.active
    return false if buyer_web_page.domain_permalink_text.blank?
    true
  end
end
