class RetailBuyerProfile < ActiveRecord::Base

    acts_as_xapian :texts => [ :first_name, :last_name, :email_address ],
       :terms => [ [ :first_name, 'F', "first_name" ], [:last_name, 'L', "last_name"], [:email_address, 'E', "email"]]

       # :values => [ [ :created_at, 0, "created_at", :date ] ]
  uses_guid
  belongs_to :user_territory
  belongs_to :profile, :dependent => :destroy
  has_many :buyer_engagement_infos
  has_one :retail_profile_field_engine_index, :dependent => :destroy
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :email_address
  validates_length_of :email_address,    :within => 3..100
  validates_format_of :email_address, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_acceptance_of   :terms_of_use, :message=>"You must agree to the terms of use"
  EMAIL_TYPE = {
    :squeeze_trust_responder => "squeeze_trust_responder",
    :retail_trust_responder => "retail_trust_responder",
    :daily_notification => "daily_notification",
    :weekly_notification => "weekly_notification",
    :welcome_notification => "welcome_notification"
    }
  PROPERTY_TYPE = {
    :single_family_home => "Single Family Home",
    :multi_family => "Multi Family",
    :condo_town_home =>"Condo/Townhome",
    :vacant_lot => "Vacant Lot",
    :acreage => "Acreage",
    :other=> "Other"
    }
   SUBSCRIPTION_COLUMN_NAME = {
    :daily_email_subscription => "daily_email_subscription",
    :weekly_email_subscription => "weekly_email_subscription",
    :trust_responder_subscription => "trust_responder_subscription",
    :welcome_email_subscription => "welcome_email_subscription"
    }

  RETAIL_BUYER_PROFILE_DELETE_REASON = ["bought_sold_the_property", "buyer_bought_the_property", "other"]
  RETAIL_BUYER_PROFILE_DELETE_REASON_NAME = { "bought_sold_the_property" => "I bought/sold the property", "buyer_bought_the_property" => "Buyer bought the property", "other" => "Other" }

    def after_save
        squeeze_page_opt_ins = SqueezePageOptIn.find(:all,:conditions=>["retail_buyer_email = ? " ,self.email_address])
        squeeze_page_opt_ins.each do |squeeze_page_opt_in|
         squeeze_page_opt_in.destroy
        end
    end

end
