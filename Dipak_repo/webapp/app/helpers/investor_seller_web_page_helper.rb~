module InvestorSellerWebPageHelper

  def company_name
    return @user_company_info.business_name unless @user_company_info.nil?
  end

  def business_phone
    return @user_company_info.business_phone unless @user_company_info.nil?
  end
  
  def get_ga_tracking_code(permalink)
    seller_website = SellerWebsite.find_by_permalink_text(permalink)
    
    if !seller_website.nil?
      ua_number = seller_website.ua_number
      ga_code = "var _gaq = _gaq || [];
    _gaq.push(['_setAccount', \'#{ua_number}\']);
    _gaq.push(['_trackPageview']);
    
    (function() {
       var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
       ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
       var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
     })();"
      return ga_code
    else
      return ""
    end
  end
end
