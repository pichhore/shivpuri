class ReiWebsitesController < ApplicationController
  before_filter :login_required
  layout "application"

  include ReiWebsitesHelper
 
  def index
    @my_websites = current_user.my_websites.find(:all, :conditions => [ " site_type in (?)",[ @website_type.capitalize + "Website", @website_type.capitalize + "WebPage"]] ) || []

    if has_old_format_webpages?
      @rei_domains = ["www.ownhome4.us", "www.buyhome4.us"]
      @my_website_form = MyWebsiteForm.new
    end

    render :template => "/rei_websites/index"
  end

  def step1
    case @website_type
    when "buyer"
      @rei_domains = ["www.ownhome4.us", "www.buyhome4.us"]
      @steps = 3
    when "seller"
      render :file => "#{RAILS_ROOT}/public/404.html" and return if current_user.seller_websites.size == 2 and !current_user.admin?
      @rei_domains = ["www.need2sell.us", "www.sellhouse2.us"]
      @steps = 2
      @my_websites = current_user.my_websites.find(:all, :conditions => [ " site_type in (?)",[ @website_type.capitalize + "Website", @website_type.capitalize + "WebPage"]] ) || []
    end
    @my_website_form = MyWebsiteForm.new
    
    render :template => "/rei_websites/step1"
  end

  # Need to implement logic to check uniqueness with in the domain
  def check_permalink
    if !params.blank?
      render :text => "<div class='message_in_red'>Please select a domain.</div>", :layout=>false and return if params[:domain_name].blank?
      if !params[:permalink].blank?
        my_website = if @website_type == 'buyer'
          MyWebsite.buyer_page_with_permalink(params[:domain_name], params[:permalink])
        elsif @website_type == 'seller'
          SellerWebsite.find(:all, :conditions => ["permalink_text=?",params[:permalink]])
        else
          InvestorWebsite.find(:all, :conditions => ["permalink_text=?",params[:permalink]])
        end

        if my_website.size > 0
          render :text => "<div class='message_in_red'>URL taken.</div>",:layout=>false
        else
          render :text => "<div class='message_in_green'>URL available.</div>",:layout=>false
        end
      else
        render :text => "<div class='message_in_red'>Please insert permalink to check.</div>",:layout=>false
      end
    else
      render :text => "<div class='message_in_red'>Error encountered.</div>",:layout=>false
    end
  end  

  def enter_domain_name
    case @website_type
    when "buyer"
      fhtaccess = File.open("#{NGINX_BUYER_CONF_FILE_PATH}","w+")
      file_content = create_buyer_domain_string
    when "seller"
      if @seller_website.seller_magnet
        fhtaccess = File.open("#{NGINX_SM_CONF_FILE_PATH}","w+")
      else       
        fhtaccess = File.open("#{NGINX_CONF_FILE_PATH}","w+")
      end
      file_content = create_seller_domain_string
    when "investor"
      fhtaccess = File.open("#{NGINX_INVESTOR_CONF_FILE_PATH}","w+")
      file_content = create_investor_domain_string
    end
    fhtaccess.puts file_content
    fhtaccess.close
  end

  def create_buyer_domain_string
    all_domains = ""
    buyer_websites = BuyerWebPage.find(:all,:conditions=>["domain_type='having'"])
    buyer_websites.each do |buyer_website|
      domain_name = buyer_website.my_website.domain_name.to_s.gsub("www.","")
      str_first =  BuyerWebPage::NGINX_BUYER_WEBSITE_CONFIG[:first] + domain_name.downcase  + BuyerWebPage::NGINX_BUYER_WEBSITE_CONFIG[:second] + "www." + domain_name.downcase  + BuyerWebPage::NGINX_BUYER_WEBSITE_CONFIG[:third]
      str_second = str_first + buyer_website.domain_permalink_text.downcase + BuyerWebPage::NGINX_BUYER_WEBSITE_CONFIG[:fourth] + BuyerWebPage::NGINX_BUYER_WEBSITE_CONFIG[:fifth] + buyer_website.domain_permalink_text.downcase + BuyerWebPage::NGINX_BUYER_WEBSITE_CONFIG[:sixth]
      all_domains = all_domains +  str_second
    end
    return all_domains
  end
  
  def create_seller_domain_string
    all_domains = ""
    seller_websites = SellerWebsite.find(:all,:conditions => {:domain_type => "having", :seller_magnet => @seller_website.seller_magnet})

    redirection = @seller_website.seller_magnet ? :fifth : :third
    seller_websites.each do |seller_website|
      domain_name = seller_website.my_website.domain_name.to_s.gsub("www.","").downcase
      str_first =  SellerWebsite::NGINX_SELLER_WEBSITE_CONFIG[:first] + domain_name  + SellerWebsite::NGINX_SELLER_WEBSITE_CONFIG[:second] + "www." + domain_name  + (@seller_website.seller_magnet? ? SellerWebsite::NGINX_SELLER_WEBSITE_CONFIG[:fifth] : SellerWebsite::NGINX_SELLER_WEBSITE_CONFIG[:third])
      str_second = str_first + seller_website.permalink_text.downcase + SellerWebsite::NGINX_SELLER_WEBSITE_CONFIG[:fourth]
      all_domains = all_domains +  str_second
    end
    return all_domains
  end

  def create_investor_domain_string
    all_domains = ""
    investor_websites = InvestorWebsite.find(:all,:conditions => ["domain_type='having'"])
    investor_websites.each do |investor_website|
      domain_name = investor_website.my_website.domain_name.to_s.downcase.gsub("www.","")
      str_first =  InvestorWebsite::NGINX_SELLER_WEBSITE_CONFIG[:first] + domain_name  + InvestorWebsite::NGINX_SELLER_WEBSITE_CONFIG[:second] + "www." + domain_name  + InvestorWebsite::NGINX_SELLER_WEBSITE_CONFIG[:third] 
      str_second = str_first + investor_website.permalink_text + InvestorWebsite::NGINX_SELLER_WEBSITE_CONFIG[:fourth]
      all_domains = all_domains +  str_second
    end
    return all_domains
  end
end
