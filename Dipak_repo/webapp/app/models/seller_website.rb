# -*- coding: utf-8 -*-
class SellerWebsite < ActiveRecord::Base
  uses_guid
  has_many :seller_profiles, :dependent => :nullify
  has_one :my_website, :as => :site,:dependent => :destroy
  belongs_to :user
  has_many :seller_lead_opt_ins
  validates_presence_of :permalink_text, :message=>"can't be empty"
  validates_uniqueness_of :permalink_text
  validates_length_of :permalink_text , :minimum => 3, :message => "is too short(minimum is %d characters)"
  validates_length_of :meta_title,:maximum => 70, :message=>"Only 70 Characters are allowed."
  validates_length_of :meta_description,:maximum =>155, :message=>"Only 155 Characters are allowed."
  validates_format_of :permalink_text, :with =>/\A[A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9]+\Z/, :message=>"Check your URL and make sure it doesn't contain spaces, periods or special characters. Numbers, Underscores (_) and Hyphens (-) are allowed "
  validates_format_of :home_page_video_tour,
                        :with => /\A(^(www.youtube.com\/watch\?v=)[0-9a-zA-Z\-\_]*$)\Z/,
                        :message => "Please enter a valid youtube URL (Ex:- www.youtube.com/watch?v=oXW476CyROg)",
                        :if => Proc.new {|seller_website| !seller_website.home_page_video_tour.blank?}
  validates_format_of :lead_funnel_video_tour,
                        :with => /\A(^(www.youtube.com\/watch\?v=)[0-9a-zA-Z\-\_]*$)\Z/,
                        :message => "Please enter a valid youtube URL (Ex:- www.youtube.com/watch?v=oXW476CyROg)",
                        :if => Proc.new {|seller_website| !seller_website.lead_funnel_video_tour.blank?}
  validates_length_of :ua_number, :is => 13, :allow_blank => true, :allow_nil => true, :message => "is the wrong length (should be %d characters)"
  validates_format_of :ua_number, :with => /^(?i)ua-\d{8}-\d{1}/, :allow_blank => true, :allow_nil => true, :message => "Invalid format, Please use the format UA-XXXXXXXX-X. 'X' implies numbers only."
  accepts_nested_attributes_for :my_website

  named_scope :active_seller_magnet, lambda{ |permalink|
    {:conditions => {:permalink_text => permalink, :active => true, :seller_magnet => true}}
  }
  SELLER_DOMAIN_NAMESPACE = "/seller-websites/"

  MONGREL_UPSTREAM_NAME = "mongrel_reimatcherstaging" if RAILS_ENV == "staging"
  MONGREL_UPSTREAM_NAME = "mongrel_production" if RAILS_ENV == "production"
  MONGREL_UPSTREAM_NAME = "mongrel_reimatcher_production_test" if RAILS_ENV == "production_test"
  MONGREL_UPSTREAM_NAME = "webrick_local" if RAILS_ENV == "development"

  # :fifth is for amps seller magnet site
  NGINX_SELLER_WEBSITE_CONFIG = {
    :first  => "set $my_flag '';\r\nif ($uri = /)\r\n{\r\nset $my_flag \"${my_flag}U\";\r\n}\r\nif ($host ~* ^(",
    :second => ")|^(",
    :third  => ")){\r\nset $my_flag \"${my_flag}H\";\r\n}\n\rif ( $my_flag = UH){\n\rrewrite      /  /s/",
    :fourth => "/  last;\r\nproxy_pass    http://#{MONGREL_UPSTREAM_NAME};\r\n}\r\n",
    :fifth  => ")){\r\nset $my_flag \"${my_flag}H\";\r\n}\n\rif ( $my_flag = UH){\n\rrewrite      /  /m/"
  }

  HOME_PAGE_TEXT1= "Welcome...if you're <b> Looking to Sell Your Property </b> , you've come to the right place!<br><br>We represent a network of literally thousands of real estate investors and a handful of very specially trained Realtors that focus on \"non-traditional\" or \"creative\" real estate solutions \".<br><br>If you are like most sellers, you want to explore how to sell your property fast and hassle free. We can help! That’s what we do...<br><br><b> We Buy Properties Fast...</b> regardless of condition, equity, or situation. We’ve handled just about every situation you can imagine.  We buy with cash. We even have many creative solutions available. We are experts. <br><br>For example, did you know there are at least a <b> 12 Different Ways to Sell Your Property </b> that Realtors won’t tell you about? <br><br>"

  HOME_PAGE_TEXT2="Most Realtors are not trained on these options and don’t know about them.  Some Realtors know about some of these options, but don’t talk about them with you because many of these solutions simply don’t pay them a commission.<br><br>These transactions include <b> Fast Cash Offers </b> from investors, as well as wraps, options, auctions, swaps, shorts, assignments, and many more...<br><br>These transactions usually involve selling your property to our network of investors who compete to buy your property quickly, in any condition, and regardless of the amount of equity in the property. <br><br>Our investors buy properties for all different purposes including to keep as rental properties, or to resell, possibly after making improvements, or to resell with owner financing and/or on a rent-to-own plan, or even to just live in themselves. <br><br>We’d like to talk to you about your options!<b>  We'd Like To Buy Your Property!</b> <br><br>Our offers can even sometimes be combined with traditional listings using what we call \"combo plans\" that allow sellers to work with specially trained real estate agents and investors simultaneously to provide property owners with both a plan A and plan B for selling their property.<br><br>Wanna hear more? Feel free to explore our website and <b> Let Us Know How We Can Help!</b> <br><br>"

  ABOUT_TEXT = " <b>{Subscriber Company name}</b> is part of a national network of investors and Realtors that specialize in buying properties FAST using advanced, non-traditional, real estate techniques that are squarely focused on the client.  We’ve studied the market and created a website for you to use to help you pick the solution that best works for your unique needs.  We would love to have a conversation with you so that we may understand your specific situation and work together to find a solution that best allows you to achieve your goals.  Together we can come up with a targeted solution that helps you.<br/><br/>Traditional Real Estate involves hiring a Realtor to list your home on the MLS while waiting for a buyer, with a conventional loan, to show up with an offer.<br><br/>Traditional real estate works for many, but it typically takes a long time, can be very expensive, and is less and less suitable for the millions of sellers that want or need to SELL FAST, don’t want the hassles of dealing with Realtors and a parade of picky buyers, and in many cases do not even have the equity, repair resources, or the luxury of time needed to pursue traditional real estate solutions.<br><br/> If you want to SELL FAST, we can help and have methods for buying homes QUICKLY regardless of the home’s condition, the seller’s financial situation, or even the amount of equity in the home.<br><br>We specialize in solving difficult problems. We’ve seen it all and that’s why we know we are positioned to find your solution.<br><br>At <b>{Subscriber Company name}</b>, we are wholeheartedly focused on helping people that need to sell their homes and are having difficulty working through the traditional channels that don’t meet the needs of homeowners in today’s market. We offer truly unique solutions because each and every homeowner has their own goals and together, we can achieve them.<br>"
  
  HEADER_TEXT = "Need to Sell your House This Week? You're in the right place. We buy houses fast!"
  
  META_DESCRIPTION = "We Buy Houses Fast…specialize in . We are part of a network of thousands of Investors and Home Buyers and may have already sold your property"
  
  META_TITLE = "Need to Sell Fast > Any House Any Condition"

  LANDING_PAGE_HEADLINE = "Sell your home FAST at NO COST and NO HARM to your credit (in weeks not months)!"
  
  RESULTS_PAGE_COPY = "To Find Out More About This New Program And How You Can Quickly And Easily Sell Your House For FULL Market Value (Even If It’s Currently Listed For Sale), Please Watch The Video Below..."

  RESULTS_PAGE_CONTENT = "Join Thousands of Homeowners just like you around the country who have been successful in selling their home using the  Assignment of Mortgage Payment Program.<br/><br/>This program allows you to sell your home Fast and with No Harm to your Credit...even if you have little, no, or negative equity in your home.<br/><br/>There is No Cost to you and you are under No Obligation to use this program."

  THANKYOU_PAGE_HEADLINE = "A Member of Our Network Will Be Contacting You Soon!"
  
  THANKYOU_PAGE_COPY = "Thank you for submitting your house to our Nationwide Buyers Network. You could receive offers within days. Now, please watch our informative video below. In it, we answer the most common questions about our program."

  def self.find_by_active_permalink(perma_text)
    seller_website = find_by_permalink_text(perma_text)
    return seller_website if !seller_website.nil? and seller_website.active
    return nil
  end

  def having?
    domain_type == 'having'
  end

  def site_url
    return nil if permalink_text.blank?
    if having? && my_website
      "http://#{my_website.domain_name.to_s.downcase}"
    elsif my_website
      "http://#{my_website.domain_name}/#{permalink_text}"
    end
  end

  def seller_magnet_color
    case dynamic_css
    when "rgb(88, 137, 205)"
      "blue"
    when "rgb(55, 156, 122)"
      "green"
    when "rgb(141, 60, 34)"
      "brown"
    else
      "blue"
    end
  end
end
