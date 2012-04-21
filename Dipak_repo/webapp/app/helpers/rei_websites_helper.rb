module ReiWebsitesHelper

  def has_old_format_webpages?
    false if @website_type != 'buyer'
    buyer_pages.empty? ? false : true
  end

  def buyer_pages
    current_user.user_territories.map{ |x| x.buyer_web_page if x.buyer_web_page && x.buyer_web_page.domain_permalink_text.blank? }.compact
  end

  def buyer_territory buyer_page
    buyer_page.user_territory.territory
  end
end
