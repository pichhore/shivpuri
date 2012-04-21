require "validatable"
class MyWebsiteForm 
    include Validatable
    DOMAIN_TYPE = { :buying => "buying", :having => "having",:reim=>"reim"}
    REIM_DOMAIN_NAME = {:first => "www.need2sell.us",:second=>"www.sellhouse2.us",:third => "www.ownhome4.us",:fourth=>"www.buyhome4.us"}

    BUYER_DOMAINS = ["www.buyhome4.us", "www.ownhome4.us"]

    FIELDS = [:domain,:having_domain_name,:reim_domain_permalink1,:reim_domain_permalink2,:reim_domain_name]
    validates_presence_of :domain, :message => 'Please select any domain.'
    
    validates_length_of :reim_domain_permalink1 , :minimum => 3,:if => Proc.new { [ REIM_DOMAIN_NAME[:first], REIM_DOMAIN_NAME[:third] ].include?(reim_domain_name) && domain == DOMAIN_TYPE[:reim]}, :message => 'The permalink text should be more than 2 letters.'
    validates_length_of :reim_domain_permalink2 , :minimum => 3,:if => Proc.new { [ REIM_DOMAIN_NAME[:second], REIM_DOMAIN_NAME[:fourth] ].include?(reim_domain_name) && domain == DOMAIN_TYPE[:reim]}, :message => 'The permalink text should be more than 2 letters.'

    validates_format_of :reim_domain_permalink1, :with =>/\A[A-Za-z0-9]+[A-Za-z_-]+[A-Za-z0-9]+\Z/, :message=>"Check your URL and make sure it doesn't contain spaces, periods or special characters. Numbers, Underscores (_) and Hyphens (-) are allowed ",:if => Proc.new { [ REIM_DOMAIN_NAME[:first], REIM_DOMAIN_NAME[:third] ].include?(reim_domain_name) && domain == DOMAIN_TYPE[:reim] && reim_domain_permalink2.blank?}

    validates_format_of :reim_domain_permalink2, :with =>/\A[A-Za-z0-9]+[A-Za-z_-]+[A-Za-z0-9]+\Z/, :message=>"Check your URL and make sure it doesn't contain spaces, periods or special characters. Numbers, Underscores (_) and Hyphens (-) are allowed ",:if => Proc.new { [ REIM_DOMAIN_NAME[:second], REIM_DOMAIN_NAME[:fourth] ].include?(reim_domain_name) && domain == DOMAIN_TYPE[:reim] && reim_domain_permalink1.blank?}

    validates_presence_of :having_domain_name, :message => 'Please insert domain name.',:if => Proc.new {domain == DOMAIN_TYPE[:having]}
    
    validates_format_of :having_domain_name, :with => /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?$/ix,:if => Proc.new {domain == DOMAIN_TYPE[:having]}, :message => "Invalid domain name. You domain name should be like www.example.us or example.com"
    
    validates_presence_of :reim_domain_name, :message => 'Please select any REIM domain.',:if => Proc.new {domain == DOMAIN_TYPE[:reim] }
    validates_presence_of :reim_domain_permalink1, :message => 'Please insert the permalink.',:if => Proc.new { reim_domain_name ==REIM_DOMAIN_NAME[:first] && domain == DOMAIN_TYPE[:reim]}
    validates_presence_of :reim_domain_permalink2, :message => 'Please insert the permalink.',:if => Proc.new { reim_domain_name == REIM_DOMAIN_NAME[:second] && domain == DOMAIN_TYPE[:reim]}
    create_attrs FIELDS
 
  validates_true_for :duplicate_reim_domain_permalink1,
                     :if => Proc.new { 
                       [ REIM_DOMAIN_NAME[:first], REIM_DOMAIN_NAME[:third] ].include?(reim_domain_name) && domain == DOMAIN_TYPE[:reim] }, :logic => lambda { duplicate_reim_domain_permalink1 }
  
  validates_true_for :duplicate_having_domain_name,:if => Proc.new { domain == DOMAIN_TYPE[:having] }, :logic => lambda { duplicate_having_domain_name}
  
  validates_true_for :duplicate_reim_domain_permalink2,
                     :if => Proc.new { 
                       [ REIM_DOMAIN_NAME[:second], REIM_DOMAIN_NAME[:fourth] ].include?(reim_domain_name) && domain == DOMAIN_TYPE[:reim] }, :logic => lambda { duplicate_reim_domain_permalink2 }

  def duplicate_having_domain_name
    having_domain_name1 = having_domain_name.downcase.gsub("www.","")
    having_domain_name2 = "www." + having_domain_name1
    my_website = MyWebsite.find(:all,:conditions=>["domain_name LIKE ? or domain_name LIKE ?",having_domain_name1,having_domain_name2])
    if !my_website.blank?
      errors.add(:having_domain_name, "This URL is already taken")
      return false
    else
      return true
    end
  end
  
  def duplicate_reim_domain_permalink1
    if BUYER_DOMAINS.include?(reim_domain_name)
      my_website = MyWebsite.buyer_page_with_permalink(reim_domain_name, reim_domain_permalink1).first
    else
      my_website =  MyWebsite.find_by_sql(["select * from my_websites where site_id in (select id from seller_websites where permalink_text=?) ",reim_domain_permalink1])
    end
    
    if !my_website.blank?
      errors.add(:reim_domain_permalink1, "This URL is already taken")
      return false
    else
      return true
    end
  end
  
  def duplicate_reim_domain_permalink2
    if BUYER_DOMAINS.include?(reim_domain_name)
      my_website = MyWebsite.buyer_page_with_permalink(reim_domain_name, reim_domain_permalink2).first
    else
      my_website =  MyWebsite.find_by_sql(["select * from my_websites where site_id in (select id from seller_websites where permalink_text=?) ",reim_domain_permalink2])
    end
    
    if !my_website.blank?
      errors.add(:reim_domain_permalink2, "This URL is already taken")
      return false
    else
      return true
    end
  end
end
