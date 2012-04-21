class MyWebsite < ActiveRecord::Base
  belongs_to :site, :polymorphic => true
  belongs_to :user
  validates_format_of :domain_name, :with => /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  before_validation :duplicate_domain_name
  
  WEB_SITE_TYPE = {:seller=>"seller",:buyer=>"buyer", :investor=>"investor"}

  def duplicate_domain_name
    if !id.blank? and !self.site.blank? and self.site.having?
      having_domain_name1 = domain_name.downcase.gsub("www.","")
      having_domain_name2 = "www." + having_domain_name1
      my_website = MyWebsite.find(:all,:conditions=>["id != ? and (domain_name LIKE ? or domain_name LIKE ?)",id, having_domain_name1,having_domain_name2])
      if !my_website.blank?
        errors.add(:domain_name, "This URL is already taken")
        return false
      else
        return true
      end
    else
      return true
    end
  end
  
  def self.buyer_websites
    self.find_by_site_type("BuyerWebPage") || []
  end
  
  def self.seller_websites
    self.find_by_site_type("SellerWebsite")
  end

  def self.investor_websites
    self.find_by_site_type("InvestorWebsite")
  end

  def self.buyer_page_with_permalink domain_name, permalink
    MyWebsite.all(:conditions => ["domain_name = ? && buyer_web_pages.domain_permalink_text = ?", domain_name, permalink], :joins => "LEFT OUTER JOIN buyer_web_pages ON my_websites.site_id = buyer_web_pages.id")
  end
end
