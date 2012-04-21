module InvestorBuyerWebPageHelper
  def medium_thumbnail_image
    if @buyer_user_image.find_medium_thumbnail 
      return image_tag @buyer_user_image.public_filename(:medium), :class=>"thumbnail",:width=>50,:height=>50
    else 
      return image_tag("/images/buyer-60.jpg",:width=>50,:height=>50 )
    end 
  end
  
  def get_value(hash, key)
    if hash[key].blank? || hash[key] == key ||hash[key] == "Message (optional)" 
      if key == "message"
        return "Message (optional)"
      else
        return key.capitalize
      end
    else
      return hash['key']
    end
  end

  def buyer_page_latest_actions
    ['investor_buyer_web_page_latest', 'property_full_view_latest', 'property_view_latest', 'terms_of_use_latest', 'new_retail_buyer_zipselect_latest']
  end
end
