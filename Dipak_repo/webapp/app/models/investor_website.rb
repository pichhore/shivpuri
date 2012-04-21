class InvestorWebsite < ActiveRecord::Base
  uses_guid
  has_one :my_website, :as => :site,:dependent => :destroy
  has_one :investor_website_links
  belongs_to :user
  has_one :investor_website_image, :dependent=>:destroy
  validates_presence_of :permalink_text, :message=>"can't be empty"
  validates_uniqueness_of :permalink_text
  validates_length_of :permalink_text , :minimum => 3, :message => "is too short(minimum is %d characters)"
  validates_format_of :permalink_text, :with =>/\A[A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9]+\Z/, :message=>"Check your URL and make sure it doesn't contain spaces, periods or special characters. Numbers, Underscores (_) and Hyphens (-) are allowed "
  validates_length_of :ua_number, :is => 13, :allow_blank => true, :allow_nil => true, :message => "is the wrong length (should be %d characters)"
  validates_format_of :ua_number, :with => /^(?i)ua-\d{8}-\d{1}/, :allow_blank => true, :allow_nil => true, :message => "Invalid format, Please use the format UA-XXXXXXXX-X. 'X' implies numbers only."
  accepts_nested_attributes_for :my_website
  SELLER_DOMAIN_NAMESPACE = "/investor-websites/"

  MONGREL_UPSTREAM_NAME = "mongrel_reimatcherstaging" if RAILS_ENV == "staging"
  MONGREL_UPSTREAM_NAME = "mongrel_production" if RAILS_ENV == "production"
  MONGREL_UPSTREAM_NAME = "mongrel_reimatcher_production_test" if RAILS_ENV == "production_test"
  MONGREL_UPSTREAM_NAME = "" if RAILS_ENV == "development"

  NGINX_SELLER_WEBSITE_CONFIG = {
       :first=>"set $my_flag '';\r\nif ($uri = /)\r\n{\r\nset $my_flag \"${my_flag}U\";\r\n}\r\nif ($host ~* ^(",
       :second=>")|^(",
      :third=>")){\r\nset $my_flag \"${my_flag}H\";\r\n}\n\rif ( $my_flag = UH){\n\rrewrite      /  /i/",
      :fourth=>"/  last;\r\nproxy_pass    http://#{MONGREL_UPSTREAM_NAME};\r\n}\r\n"
             }
    HOME_PAGE_TEXT1= ""

    HOME_PAGE_TEXT2=""

    ABOUT_TEXT = ""
  
 HEADER_TEXT = ""
 
 BANNER_IMAGE_PATH = { 1 => "images/banner.jpg", 2 => "images/option2.jpg", 3 => "images/option3.jpg", 4 => "images/option4.jpg", 5 => "images/option5.jpg"}
 
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

  def self.find_by_active_permalink(perma_text)
    investor_website = find_by_permalink_text(perma_text)
    return investor_website if !investor_website.nil? and investor_website.active
    return nil
  end
end
