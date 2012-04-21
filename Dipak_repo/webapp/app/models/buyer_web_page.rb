class BuyerWebPage < ActiveRecord::Base
  uses_guid
  belongs_to :user_territory
  has_one :my_website, :as => :site,:dependent => :destroy

  validates_presence_of :domain_permalink_text, :message => "can't be empty"
  validates_length_of :domain_permalink_text , :minimum => 3, :message => "is too short(minimum is %d characters)"
  validates_format_of :domain_permalink_text, :with => /\A[A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9]+\Z/, :message => "Check your URL and make sure it doesn't contain spaces, periods or special characters. Numbers, Underscores (_) and Hyphens (-) are allowed"
  validates_length_of :ua_number, :is => 13, :allow_blank => true, :allow_nil => true, :message => "is the wrong length (should be %d characters)"
  validates_format_of :ua_number, :with => /^(?i)ua-\d{8}-\d{1}/, :allow_blank => true, :allow_nil => true, :message => "Invalid format, Please use the format UA-XXXXXXXX-X. 'X' implies numbers only."
  accepts_nested_attributes_for :my_website
  named_scope :active_buyer_web_page, lambda { |permalink|
    {
      :conditions => { :domain_permalink_text => permalink, :active => true}
    }
  }

  BUYER_DOMAIN_NAMESPACE = "/buyer-websites/"

  MONGREL_UPSTREAM_NAME = "mongrel_reimatcherstaging" if RAILS_ENV == "staging"
  MONGREL_UPSTREAM_NAME = "mongrel_production" if RAILS_ENV == "production"
  MONGREL_UPSTREAM_NAME = "mongrel_reimatcher_production_test" if RAILS_ENV == "production_test"
  MONGREL_UPSTREAM_NAME = "webrick_local" if RAILS_ENV == "development"

  MONGREL_UPSTREAM_NAME = "webrick_local" if RAILS_ENV == "development"

  NGINX_BUYER_WEBSITE_CONFIG = {
    :first=>"set $my_flag '';\r\nif ($uri = /)\r\n{\r\nset $my_flag \"${my_flag}U\";\r\n}\r\nif ($uri = /2)\r\n{\r\nset $my_flag \"${my_flag}Q\";\r\n}\r\nif ($host ~* ^(",
    :second=>")|^(",
    :third=>")){\r\nset $my_flag \"${my_flag}H\";\r\n}\n\rif ( $my_flag = UH){\n\rrewrite      /  /b/",
    :fourth=>"/  last;\r\nproxy_pass    http://#{MONGREL_UPSTREAM_NAME};\r\n}\r\n",
    :fifth=>"if ( $my_flag = QH){\n\rrewrite      /  /b/",
    :sixth=>"/2  last;\r\nproxy_pass    http://#{MONGREL_UPSTREAM_NAME};\r\n}\r\n"
  }

  def having?
    domain_type == 'having'
  end

  def having_or_buying?
    domain_type == MyWebsiteForm::DOMAIN_TYPE[:having] || domain_type == MyWebsiteForm::DOMAIN_TYPE[:buying]
  end

  def validate
    if self.domain_permalink_text_changed? && duplicate_permalink?
      errors.add :domain_permalink_text, 'This URL is already taken'
    end
  end

  def duplicate_permalink?
    user = self.user_territory.user
    if my_website = user.my_websites.select{|x| x.site_id == self.id}.first
      return true if MyWebsite.buyer_page_with_permalink(my_website.domain_name, self.domain_permalink_text).first
    end
    return false
  end

  def old_format_site?
    domain_permalink_text.blank?
  end

  def new_format_url
    return nil if domain_permalink_text.blank?
    if having? && my_website
      "#{my_website.domain_name.to_s.downcase}"
    elsif my_website
      "#{my_website.domain_name}/#{domain_permalink_text}"
    end
  end

  def new_format_url_for_retail_buyer
    return nil if domain_permalink_text.blank?
    if having? && my_website
      "http://#{my_website.domain_name.to_s.downcase}/b/#{domain_permalink_text}"
    elsif my_website
      "http://#{my_website.domain_name}/b/#{domain_permalink_text}"
    end
  end

  def new_format_url_for_syndication
    return nil if domain_permalink_text.blank?
    if having? && my_website
      "http://#{my_website.domain_name.to_s.downcase}"
    elsif my_website
      "http://#{my_website.domain_name}/#{domain_permalink_text}"
    end
  end

  def buyersite_url
    domain_name = my_website.domain_name
    domain_name += ("/" + domain_permalink_text) unless having?
  end

  protected
  
  def scope_on_territory?
    begin
      user_territory = UserTerritory.find(:first,:conditions=>["id  = ?",self.user_territory_id])
      unless user_territory.blank?
        get_all_user_territory = UserTerritory.find(:all,:conditions=>["territory_id  = ?",user_territory.territory_id])
        return_true = false
        get_all_user_territory.each do |u_territory|
          if !u_territory.buyer_web_page.nil? && u_territory.buyer_web_page.id != self.id && u_territory.buyer_web_page.permalink_text == self.permalink_text
              return_true = true
          end
        end
        return return_true
      else
        return false
      end
    rescue
       return true
    end
 end
  def get_territory_reim_name
    UserTerritory.find_by_id(self.user_territory_id).territory.reim_name || ""
  end
end

