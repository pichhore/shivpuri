class Badge < ActiveRecord::Base
  has_one :badge_image, :dependent=>:destroy
  has_many :badge_users, :dependent=>:destroy
  has_many :users, :through=>:badge_users
  validates_presence_of :name
  validates_uniqueness_of :name, :message => " Enter only unique name"
  validates_numericality_of :profiles_added, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"
  validates_numericality_of :properties_added, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"
  validates_numericality_of :properties_sold, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"
  validates_numericality_of :membership_time, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"
  validates_numericality_of :sellers_added, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"
  validates_numericality_of :deals_completed, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"
  validates_numericality_of :investor_messages_sent, :only_integer => true, :allow_nil => true, :message => " Enter only integer value"

  named_scope :get_badges_whose_certification_is_null, :conditions => "certification is null or certification = ''"
end
