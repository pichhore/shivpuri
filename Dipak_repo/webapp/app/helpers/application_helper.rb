require 'tzinfo'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def development?
    return RAILS_ENV == "development"
  end

  def staging?
    return RAILS_ENV == "staging"
  end

  def production?
    return RAILS_ENV == "production"
  end

  def is_your_own_buyer_profile?(profile_user_id)
     (!current_user.blank? and profile_user_id == current_user.id) ? true : false
  end

  # NOTE: Still under development - untested
  def render_xhr_action_or_default(xhr_action_hash, default_action_hash)
    if request.xhr?
      render xhr_action_hash
    else
      render default_action_hash
    end
  end

  #
  # Renders a check_box_tag for an array field, setting the value to checked if the value is found in the request params
  #
  # Since ActiveRecord doesn't generate array-based fields for database columns, this allows a form to have multiple
  # checkboxes under a specific object and field name that will produce an array on the server side for processing.
  #
  # Example:
  #
  #         check_box_tag_for_array "profile_message_form","filters","all"
  #
  # produces the HTML
  #
  #         <input id="profile_message_form[filters][]"
  #                name="profile_message_form[filters][]"
  #                type="checkbox"
  #                value="all"
  #                checked="checked" />
  #
  # when the array @params["profile_message_form[filters][]"] includes the value "all"
  #
  # and
  #
  #         <input id="profile_message_form[filters][]"
  #                name="profile_message_form[filters][]"
  #                type="checkbox"
  #                value="all" />
  #
  # when the array @params["profile_message_form[filters][]"] is nil or does NOT include the value "all"
  #
  def check_box_tag_for_array(object_name, field_name, checked_value)
    checked = nil
    if params[object_name] and params[object_name][field_name]
      checked = params[object_name][field_name].include?(checked_value)
    end
    return check_box_tag("#{object_name}[#{field_name}][]","#{checked_value}",checked)
  end

  def render_tip(target_page)
    tip,index = Tip.find_next_tip_with_index(target_page, session[:last_tip_index])
    session[:last_tip_index] = index
    return "Tip: #{tip.tip_text}" if !tip.nil?
    return nil
  end

  def render_ad(*args)
    #return "<!-- Skippings Ads -->" if development?
    options = args.last.is_a?(Hash) ? args.pop : {}
    height = options[:height]
    width = options[:width]
    image = options[:image]
    link = options[:link]
    target_page = options[:target_page]

    if !target_page.nil?
      # Latest version - use the name to load the ad first
      ad,index = Ad.find_next_ad_with_index(target_page, session["last_ad_index_#{target_page}"])
      session["last_ad_index_#{target_page}"] = index
      if ad.nil?
        return "<!-- Ad not found: #{target_page} -->"
      end

      user_id = current_user.id if logged_in?
      profile_id = @profile.id if @profile
      # track each time we show the ad
      AdView.create!({ :ad_id=>ad.id, :user_id=>user_id, :profile_id=>profile_id})
      return link_to(image_tag("#{ad.image_path}", :width=>ad.width, :alt=>"", :title=>""), ad_path(ad), :target=>"_new", :class=>"banner_ad")
    end

    return "<!-- Ad: Missing target page -->"
  end

#  def render_ad(*args)
#    options = args.last.is_a?(Hash) ? args.pop : {}
#    height = options[:height]
#    width = options[:width]
#    image = options[:image]
#    link = options[:link]
#    name = options[:name]
#
#    if !name.nil?
#      # Latest version - use the name to load the ad first
#      ad = Ad.find_by_name(name)
#      if ad.nil?
#        return "<!-- Ad not found: #{name} -->"
#      end
#
#      user_id = current_user.id if logged_in?
#      profile_id = @profile.id if @profile
#      # track each time we show the ad
#      AdView.create!({ :ad_id=>ad.id, :user_id=>user_id, :profile_id=>profile_id})
#
#      return link_to(image_tag("#{ad.image_path}", :width=>ad.width, :alt=>"", :title=>""), ad_path(ad), :target=>"_new", :class=>"banner_ad")
#    end
#
#    # fallback - this is the oldest version - used as a placeholder
#    return "<p style=\"clear: both; height: #{height-2}px; width: #{width-3}px; text-align: center; background: #FFFFFF; padding: 0; margin-top: 5px; margin-left: 0; margin-bottom: 13px; color: #ccc; border: 1px solid #ccc;\">Adspace #{width}x#{height}</p>" if !image
#
#    # fallback - this is an older version - no click tracking (should be removed soon)
#    return link_to(image_tag("ads/#{image}", :width=>240, :alt=>"", :title=>""), "#{link}", :target=>"_new", :class=>"banner_ad")
#  end

  def render_nav_link(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    title = options[:title]
    link = options[:link]
    type = options[:type]
    return "<a class=\"navigation_menu\" remote_link=\"#{link}\" href=\"#\" link_type=\"#{type}\">#{title}</a>"
  end

  def render_thumbnail(profile=@profile, options_hash={}, index=1)
    if profile.buyer?
      begin 
        return image_tag(profile.user.buyer_user_image.public_filename(:profile), options_hash.merge({ :width=>60 })) if profile.user.buyer_user_image
      rescue
        return image_tag(profile.thumbnail_url(index), options_hash.merge({ :width=>60 }))
      end
    end
    return image_tag(profile.default_image_url, options_hash.merge({ :width=>60 }))
  end

  def render_thumbnail_micro(profile=@profile, options_hash={}, index=1)
    
    image_tag(profile.thumbnail_micro_url(index), options_hash.merge({ :width=>50, :uri=>profile.photo_fullsize_url(index) }))
  end

  def render_property_thumbnail_micro(profile=@profile, options_hash={}, index=1)
    image_tag(profile.property_thumbnail_micro_url(index), options_hash.merge({ :width=>50, :uri=>profile.photo_fullsize_url(index) })) if profile.property_thumbnail_micro_url(index)
  end

  def render_photo_full_size(profile=@profile, options_hash={}, index=1)
    image_tag(profile.photo_fullsize_url(index), options_hash.merge({ :width=>170, :uri=>profile.photo_fullsize_url(index) })) 
  end

  def render_photo_fullsize(profile=@profile, options_hash={}, index=1)
    if profile.buyer?
      begin 
        return image_tag(profile.user.buyer_user_image.public_filename(:profile), options_hash.merge({ :width=>170 })) if profile.user.buyer_user_image
      rescue
        return image_tag(profile.photo_fullsize_url(index), { :width=>170 }.merge(options_hash))
      end
    end
    image_tag(profile.photo_fullsize_url(index), { :width=>170 }.merge(options_hash))
  end

  def render_photo_bigsize(profile=@profile, options_hash={}, index=1)
    image_tag(profile.photo_bigsize_url(index), { :width=>170 }.merge(options_hash))
  end


  # dashboard and other old-style zoomed
  def render_privacy_icon_zoomed(profile, alt_text, options={ })
    alt_text = display_property_type_with_privacy(profile.field_value(:property_type), profile.display_privacy)
    return image_tag("gmap/detail/icon_detail_#{profile.public_profile? ? 'public' : 'private'}_#{profile.field_value( :property_type )}.gif", :alt=>alt_text, :title=>alt_text)
   end
  # new numbered pushpin and detail image support
  def render_detail_privacy_icon(profile, alt_text, index=1)
    alt_text = display_property_type_with_privacy(profile.field_value(:property_type), profile.display_privacy)
    return image_tag("gmap/detail_icons/detail_#{profile.public_profile? ? 'public' : 'private'}_#{profile.field_value( :property_type )}_#{index}.gif", :alt=>alt_text, :title=>alt_text)
  end

  # icon next to the full page profile privacy name
  def render_privacy_icon(profile, size=:large, options={ })
    if profile.public_profile?
      return render_public_icon(profile.property_type, size, options)
    end

    return render_private_icon(profile.property_type, size, options)
  end

  # legend - public side
  def render_public_icon(property_type, size=:large, options={ })
    alt_text = display_property_type_with_privacy(property_type, "Public")
    return image_tag(ZipCodeMap.get_icon(property_type, :public).options[:image], options.merge({ :height=>17, :width=>10, :alt=>alt_text, :title=>alt_text})) if size == :small
    return image_tag(ZipCodeMap.get_icon(property_type, :public).options[:image], options.merge({ :height=>24, :width=>15, :alt=>alt_text, :title=>alt_text})) if size == :medium
    return image_tag(ZipCodeMap.get_icon(property_type, :public).options[:image], options.merge({ :alt=>alt_text, :title=>alt_text}))
  end

  # legend - private side
  def render_private_icon(property_type, size=:large, options={ })
    alt_text = display_property_type_with_privacy(property_type, "Private")
    return image_tag(ZipCodeMap.get_icon(property_type, :private).options[:image], options.merge({ :height=>17, :width=>10, :alt=>alt_text, :title=>alt_text})) if size == :small
    return image_tag(ZipCodeMap.get_icon(property_type, :private).options[:image], options.merge({ :height=>24, :width=>15, :alt=>alt_text, :title=>alt_text})) if size == :medium
    return image_tag(ZipCodeMap.get_icon(property_type, :private).options[:image], options.merge({ :alt=>alt_text, :title=>alt_text}))
  end

  def render_property_photo_icon(profile=@profile, options_hash={})
    begin
      return image_tag("/images/icons/iconCamera.png", options_hash.merge({ :width=>22, :height=>20 }))  if !profile.blank? && profile.owner? && !profile.profile_images.blank? && profile.profile_images.size > 0 
    rescue
    end
  end

  def render_property_video_icon(profile=@profile, options_hash={})
    begin
      return image_tag("/images/icons/iconFilm.png", options_hash.merge({ :width=>20, :height=>22 }))  if ( !profile.blank? ) && ( profile.owner? ) && ( !profile.display_embed_video.blank? || !profile.display_video_tour.blank? )
    rescue
    end
  end

  def get_seller_website_perma_link
    amps_site = SellerWebsite.find(:first, :conditions => ["permalink_text = ?",params[:permalink_text]])
    seller_site = SellerWebsite.find(:first, :conditions => ["user_id = ? and active = ? and seller_magnet = ?", amps_site.user_id, true, false])
    return nil if seller_site.blank?
    if seller_site.having? && seller_site.my_website
      "http://#{seller_site.my_website.domain_name.to_s.downcase}/s/#{seller_site.permalink_text}/"
    elsif seller_site.my_website
      "http://#{seller_site.my_website.domain_name}/s/#{seller_site.permalink_text}/"
    end
  end 

  def get_amps_site_link
    amps_site = SellerWebsite.find(:first, :conditions => ["permalink_text = ?",params[:permalink_text]])
    return nil if amps_site.blank?
    if amps_site.having? && amps_site.my_website
      "http://#{amps_site.my_website.domain_name.to_s.downcase}/m/#{amps_site.permalink_text}/"
    elsif amps_site.my_website
      "http://#{amps_site.my_website.domain_name}/m/#{amps_site.permalink_text}/"
    end
  end


  def display_property_type_with_privacy(property_type, display_privacy)
    return "Single Family #{display_privacy}" if property_type == "single_family"
    return "Multi Family #{display_privacy}" if property_type == "multi_family"
    return "Condo/Townhome #{display_privacy}" if property_type == "condo_townhome"
    return "Vacant Lot #{display_privacy}" if property_type == "vacant_lot"
    return "Acreage #{display_privacy}" if property_type == "acreage"
    return "Other #{display_privacy}" if property_type == "other"
    return "Any"
  end

  def render_update_js(profile=@profile)
    listing_type = @listing_type || 'all'
    render_update_match_count_js(profile.count_all(listing_type),profile.count_new(listing_type),profile.count_favorites(listing_type),profile.count_viewed_me(listing_type),profile.count_messages(listing_type))
  end

  def render_total_count_update_js(profile=@profile)
    listing_type = @listing_type || 'all'
      render_update_match_count_js(profile.count_all(listing_type)+profile.near_count_all(listing_type),profile.count_new(listing_type)+profile.near_count_new(listing_type),profile.count_favorites(listing_type),profile.count_viewed_me(listing_type),profile.count_messages(listing_type))
  end

  def render_update_match_count_js(count_all="0", count_new="0", count_favorites="0", count_viewed_me="0", count_messages="0")
    return "new NL.MatchCountHelper().updateCounts('#{count_all}','#{count_new}','#{count_favorites}','#{count_viewed_me}','#{count_messages}');"
  end

  def require_js_controllers(*args)
    controllers = args.is_a?(Array) ? args : [args]
    @js_controllers = controllers
  end

  def require_js_helpers(*args)
    helpers = args.is_a?(Array) ? args : [args]
    @js_helpers = helpers
  end

  def add_js_requires
    @js_controllers ||= []
    @js_helpers ||= []
    return @js_controllers.collect { |controller| javascript_include_tag("#{controller}_controller") }.join("") +
           @js_helpers.collect     { |helper| javascript_include_tag("#{helper}_helper") }.join("")
  end

  def render_nav_class_name(base_class_name)
    # tour page
    if base_class_name == "nav-tour"
      if @controller.controller_name == "home" and (params[:action] == "tour" or params[:action].include? "top_uses_seller" or params[:action].include? "top_uses_buyer" or params[:action].include? "top_uses_investor")
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end

    # support page
    if base_class_name == "nav-support"
      if @controller.controller_name == "home" and params[:action] == "support"
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end

    # home page - remaining pages not managed above by separate tabs
    if base_class_name == "nav-home"
      if (@controller.controller_name == "home" and (params[:action] != "tour" and params[:action] != "support" and params[:action] != "preview" and !params[:action].include? "top_uses_seller" and !params[:action].include? "top_uses_buyer" and !params[:action].include? "top_uses_investor")) or @controller.controller_name == "how_it_works" or @controller.controller_name == "contest"
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end

    if base_class_name == "nav-blog"
      if (@controller.controller_name == "home" and params[:action] == "support")
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end
    
    if base_class_name == "nav-news-updates"    
      return base_class_name      
    end
    
    if base_class_name == "nav-howto"
      return base_class_name
    end

    if base_class_name == "nav-training"
      return base_class_name
    end

    if base_class_name == "nav-buyers"
      if @controller.controller_name == "profiles" and ( (params[:action] == "new" and params[:id] == "buyer") or (params[:action] == "new_buyer_zipselect"))
        return base_class_name+"-selected"
      elsif @controller.controller_name == "home" and (params[:action] == "preview" and params[:id] == "buyer")
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end

    if base_class_name == "nav-owners"
      if @controller.controller_name == "profiles" and ( (params[:action] == "new" and params[:id] == "owner"))
        return base_class_name+"-selected"
      elsif @controller.controller_name == "home" and (params[:action] == "preview" and params[:id] == "owner")
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end

   if base_class_name == "nav-mydwellgo"
     if (@controller.controller_name == "home") or (@controller.controller_name == "profiles" and (params[:action] == "new" or params[:action] == "new_buyer_zipselect")) or @controller.controller_name == "how_it_works" or @controller.controller_name == "contest"
       return base_class_name+"-selected"
     else
       return base_class_name
     end
   end

    if base_class_name == "nav-dashboard"
      if logged_in? and (@controller.controller_name == "account" and ( params[:action] == "profiles" or params[:action] == "investor_full_page" or params[:action] == "add_buyer_created") or @controller.controller_name == "home" or @controller.controller_name == "search" or (@controller.controller_name == "profiles" and ( !((params[:action] == "new" and (params[:id] == "owner" || params[:id] == "seller_agent" || params[:id] == "buyer" || params[:id] == "buyer_agent")) or params[:action] == "create" or params[:action] == "new_buyer_zipselect"))) or @controller.controller_name == "profile_view")
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end    

    if base_class_name == "nav-seller"
      if @controller.controller_name == "seller_websites" or @controller.controller_name == "profile_images" or (@controller.controller_name == "profiles" and ( (params[:action] == "new" and (params[:id] == "owner" || params[:id] == "seller_agent")) or (params[:action] == "create" and params[:id] == "owner")))
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end    

    if base_class_name == "nav-buyer"
      if (@controller.controller_name == "account" and ( params[:action] == "buyer_webpage" ) || params[:action] == "territory_helper" || params[:action] == "territory_selection" || params[:action] == "save_user_territory" || params[:action] == "save_buyer_web_page" || params[:action] == "marketing") or (@controller.controller_name == "account_marketing") or (@controller.controller_name == "profiles" and ( (params[:action] == "new" and (params[:id] == "buyer" || params[:id] == "buyer_agent")) or (params[:action] == "new_buyer_zipselect") or (params[:action] == "create" and params[:id] == "buyer") ))
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end    

    if base_class_name == "nav-admin"
      if (@controller.controller_name == "account" and ( params[:action] == "settings" || params[:action] == "company_info" || params[:action] == "digest_frequency" || params[:action] == "profile_image" ))
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end    

    if base_class_name == "nav-network"
      if (@controller.controller_name == "account" and ( params[:action] == "investor_directory_page" || params[:action] == "investor_inbox" || params[:action] == "profile_inbox"))
        return base_class_name+"-selected"
      else
        return base_class_name
      end
    end    
  end

  def display_zips(zipcode_string)
    return "" if zipcode_string.nil? or zipcode_string.empty?
    return zipcode_string.split(",").join(", ")
  end

  def display_state(state)
    return "" if state.blank?
    state_name = State.find(:first, :conditions => ["state_code = ?", state]) 
    state_name = state_name.blank? ? "" : state_name.name
    return state_name
  end

  def render_privacy_icon(profile=@profile, prefix="")
    if profile.public_profile?
      return image_tag("#{prefix}icons/icon_public.gif", :alt=>"public", :title => "Public Property")
      
    end
    return image_tag("#{prefix}icons/icon_private.gif", :alt=>"private", :title => "Private Property")
  end

  def to_local_time(time, tz = TZInfo::Timezone.get('America/Chicago'))
    return tz.utc_to_local(time)
  end

  #
  # Return to dashboard/lens on the same tab/page support (ticket #334)
  #

  def encode_return_dashboard_variables(page = nil)
    if @filter_results.nil?
    return ["page_number=#{page || @page_number}",
            "sort=#{@sort}",
            "q=#{ERB::Util.h(@query_string)}",
            "search_profile_type=#{@search_profile_type}",
            "search_property_type=#{@search_property_type}",
            "result_filter=#{@result_filter}",
            "listing_type=#{@listing_type}",
            "zip_code=#{@zip_code}",
            "property_type=#{@property_type}"].join("&")
    else
      return ["page_number=#{page || @page_number}",
            "sort=#{@sort}",
            "q=#{ERB::Util.h(@query_string)}",
            "search_profile_type=#{@search_profile_type}",
            "search_property_type=#{@search_property_type}",
            "result_filter=#{@result_filter}",
            "listing_type=#{@listing_type}",
            "zip_code=#{@zip_code}",
            "property_type=#{@property_type}",
            "filter_results[state_name]=#{@filter_results.state_name}",
            "filter_results[territory_name]=#{@filter_results.territory_name}",
            "filter_results[monthly_max]=#{@filter_results.monthly_max}",
            "filter_results[down_max]=#{@filter_results.down_max}",
            "filter_results[monthly_min]=#{@filter_results.monthly_min}",
            "filter_results[down_min]=#{@filter_results.down_min}",
            "filter_results[keywords]=#{@filter_results.keywords.to_s.gsub(/(\r)|(\n)/," ")}",].join("&")
    end
  end

  def encode_return_dashboard_params(page = nil)
    if params[:filter_results].nil?
      return ["page_number=#{page || params[:page_number]}",
            "sort=#{params[:sort]}",
            "q=#{ERB::Util.h(params[:q])}",
            "search_profile_type=#{params[:search_profile_type]}",
            "search_property_type=#{params[:search_property_type]}",
            "result_filter=#{params[:result_filter]}",
            "listing_type=#{params[:listing_type]}",
            "zip_code=#{params[:zip_code]}",
            "property_type=#{params[:property_type]}"].join("&")
    else
      return ["page_number=#{page || params[:page_number]}",
            "sort=#{params[:sort]}",
            "q=#{ERB::Util.h(params[:q])}",
            "search_profile_type=#{params[:search_profile_type]}",
            "search_property_type=#{params[:search_property_type]}",
            "result_filter=#{params[:result_filter]}",
            "listing_type=#{params[:listing_type]}",
            "zip_code=#{params[:zip_code]}",
            "property_type=#{params[:property_type]}",
            "filter_results[state_name]=#{params[:filter_results][:state_name]}",
            "filter_results[territory_name]=#{params[:filter_results][:territory_name]}",
            "filter_results[monthly_max]=#{params[:filter_results][:monthly_max]}",
            "filter_results[down_max]=#{params[:filter_results][:down_max]}",
            "filter_results[monthly_min]=#{params[:filter_results][:monthly_min]}",
            "filter_results[down_min]=#{params[:filter_results][:down_min]}",
            "filter_results[keywords]=#{params[:filter_results][:keywords].to_s.gsub(/(\r)|(\n)/," ")}"].join("&")
    end
  end

  def encode_return_dashboard_params_hidden(page=nil)
    string =  hidden_field_tag("page_number",page || params[:page_number]) + " " +
      hidden_field_tag("sort",params[:sort]) + " " +
      hidden_field_tag("q",ERB::Util.h(params[:q])) + " " +
      hidden_field_tag("search_profile_type",params[:search_profile_type]) + " " +
      hidden_field_tag("search_property_type",params[:search_property_type]) + " " +
      hidden_field_tag("result_filter",params[:result_filter]) + " " +
      hidden_field_tag("listing_type",params[:listing_type]) + " " +
      hidden_field_tag("zip_code",params[:zip_code]) + " " +
      hidden_field_tag("property_type",params[:property_type])
    
    if params[:filter_results].nil?
      return string
    else
      string += " "
      string += hidden_field_tag("filter_results[state_name]", params[:filter_results][:state_name]) + " " +
         hidden_field_tag("filter_results[territory_name]", params[:filter_results][:territory_name]) + " " +
         hidden_field_tag("filter_results[monthly_max]", params[:filter_results][:monthly_max]) + " " +
         hidden_field_tag("filter_results[down_max]", params[:filter_results][:down_max]) + " " +
         hidden_field_tag("filter_results[monthly_min]", params[:filter_results][:monthly_min]) + " " +
         hidden_field_tag("filter_results[down_min]", params[:filter_results][:down_min]) + " " +
         hidden_field_tag("filter_results[keywords]", params[:filter_results][:keywords].to_s.gsub(/(\r)|(\n)/," "))
      return string
    end   
  end
  
  def log_activity(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    begin
      ActivityLog.create!({ 
                            :activity_category_id => options[:activity_category_id],
                            :user_id => options[:user_id], :profile_id => options[:profile_id],
                            :description => options[:description], :session_id => options[:session_id], 
                            :ip_address => [:ip_address], :profile_name => options[:profile_name]
                          })
    rescue => e
      logger.error("Error trying to make an ActivityLog entry: #{e}")
    end
  end

  def stream_csv(filename, csv_string)
    #this is required if you want this to work with IE
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end

    render :text => Proc.new { |response, output|
      output.write(csv_string)
    }
  end

  def stream_csv_original(filename)

    #this is required if you want this to work with IE
     if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers["Content-type"] = "text/plain"
       headers['Cache-Control'] = 'private'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
       headers['Expires'] = "0"
     else
       headers["Content-Type"] ||= 'text/csv'
       headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
     end

    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n", :skip_blanks => true, :force_quotes=>true)
      yield csv
    }
  end

  def render_for_buyer_or_owner(profile, buyer_text, owner_text)
    return buyer_text if profile.buyer?
    return owner_text
  end

  def get_property_state_through_zip(zip)
    unless zip.blank?
      zip_record = Zip.find(:first, :conditions => ["zip = ?",zip])
      zip_record.blank? ? nil : zip_record.state
    end
  end


  # Initializes the JavaScript necessary for displaying larger popup images
  def yui_lightbox_init
    
    if YuiEditor.default_options.nil?
      config_file = File.join(RAILS_ROOT, 'config', 'yui_editor.yml')
      YuiEditor.default_options = File.readable?(config_file) ? YAML.load_file(config_file).symbolize_keys : {}  
    end
    options = YuiEditor.default_options.merge({})
    
    version = options.delete(:version) || '2.5.2'
    base_uri = options.delete(:javascript_base_uri) || '//yui.yahooapis.com'
    compression = RAILS_ENV == 'development' ? '' : '-min'
    body_class = options.delete(:body_class) || 'yui-skin-sam'
    
    result = ''
    result << stylesheet_link_tag("#{base_uri}/#{version}/build/assets/skins/sam/skin.css") + "\n" if body_class == 'yui-skin-sam'
    result << javascript_include_tag("#{base_uri}/#{version}/build/yuiloader/yuiloader-beta#{compression}.js") + "\n"
    result << javascript_include_tag("#{base_uri}/#{version}/build/yahoo-dom-event/yahoo-dom-event.js") + "\n"
    result << javascript_include_tag("#{base_uri}/#{version}/build/dragdrop/dragdrop#{compression}.js") + "\n"
    result << javascript_include_tag("#{base_uri}/#{version}/build/container/container#{compression}.js") + "\n"
    result << javascript_include_tag("yui/lightbox/lightbox.js") + "\n"
    result << javascript_include_tag("yui/lightbox/lightbox_click.js") + "\n"
    result
  end
  
  def include_yui_lightbox_if_used
    yui_lightbox_init if @uses_yui_lightbox
  end
  
  def pluralize_hide_count(count, singular, plural = nil)
    (count == 1 || count == '1') ? singular : (plural || singular.pluralize)
  end
  
  def customize_embedcode(code)
    CGI.unescapeHTML(code.gsub(/<A([^>]*[^\/])>/,'').gsub(/<\/A>/,'').gsub(/(?:width|height)\s*=\s*["']([0-9]+)["']\s*(?:width|height)\s*=\s*["']([0-9]+)["']/,'width="480" height="385"'))
  end
  
  def title_popup
    return 'Use this area to paste the "embed code" from your favorite video sharing site.  Here is an example of embed code:
    <object width="480" height="385"><param name="movie" value="a bunch of stuff"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="a bunch of stuff" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="480" height="385"></embed></object>';
  end
  
  def determine_host
    url = REIMATCHER_URL
  end

  def time_in_words(from_time, to_time = Time.now, include_seconds = false, options = {})
                                                        #Written this method due to 
                                                        #Rails 2.3.5 and Ruby 1.8.6 issues. 

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    
    case distance_in_minutes
    when 0..1
      return distance_in_minutes == 0 ?
      "less than 1 minute" :
        distance_in_minutes == 1 ? "#{distance_in_minutes} minute":"#{distance_in_minutes} minutes" unless include_seconds
      
      case distance_in_seconds
      when 0..4   then "less than 5 seconds"
      when 5..9   then "less than 10 seconds"
      when 10..19 then "less than 20 seconds"
      when 20..39 then "half a minute"
      when 40..59 then "less than 1 minute"
      else             "1 minute"
      end
    
    when 2..44           then "#{distance_in_minutes} minutes"
    when 45..89          then "about 1 hour"
    when 90..1439        then "about #{ (distance_in_minutes.to_f / 60.0).round} hours"
    when 1440..2529      then "1 day"
    when 2530..43199     then "#{(distance_in_minutes.to_f / 1440.0).round} days"
    when 43200..86399    then "about 1 month"
    when 86400..525599   then "#{(distance_in_minutes.to_f / 43200.0).round} months"
    else
      distance_in_years           = distance_in_minutes / 525600
      minute_offset_for_leap_year = (distance_in_years / 4) * 1440
      remainder                   = ((distance_in_minutes - minute_offset_for_leap_year) % 525600)
      if remainder < 131400
        "about #{distance_in_years} years"
      elsif remainder < 394200
        "over #{distance_in_years} years"
      else
        "almost #{distance_in_years + 1} years"
      end
    end
  end

  def create_website_url(my_website)
    url_string = my_website.domain_name

    if MyWebsiteForm::REIM_DOMAIN_NAME.has_value?(my_website.domain_name)
      if my_website.site.permalink_text
        url_string = url_string +"/" + my_website.site.permalink_text
      else
        url_string = url_string +"/" + my_website.site.domain_permalink_text
      end
    end
      return url_string
  end

  def company_name
    user_company_info = current_user.user_company_info
    if !user_company_info.nil?
      return user_company_info.business_name 
    else
     return "{Subscriber Company name}"
    end
  end

  def fetch_my_website site
     current_user.my_websites.select{|x| x.site_id == site.id}.first
  end

  def buyer_webpage_url(my_site)  
    if !my_site.nil?
      url_string = my_site.domain_name
      if url_string == MyWebsiteForm::REIM_DOMAIN_NAME[:third] || url_string == MyWebsiteForm::REIM_DOMAIN_NAME[:fourth]
        url_string = url_string +"/" + (my_site.site.domain_permalink_text.empty? ? my_site.site.permalink_text : my_site.site.domain_permalink_text) 
      end
      return url_string
    else
      return ""
    end
  end
 
  def latest_buyer_webpage_actions
    ["investor_buyer_web_page_latest", "property_full_view_latest", "property_view_latest", "terms_of_use_latest", "new_retail_buyer_zipselect_latest", "select_zip_code_latest", "new_retail_buyer_latest", "sequeeze_page"]
  end

  def ga_code(permalink)
    return if permalink.blank?
    buyer_sites = BuyerWebPage.active_buyer_web_page(permalink)

    if !buyer_sites.blank? && buyer_sites.size > 1
      host = request.host.match(/www/).nil? ? "www.#{request.host}" : request.host
      buyer_website = buyer_sites.select{|x| x.my_website.domain_name == host if x.my_website}.first
    else
      buyer_website = buyer_sites.first
    end

    logger.info "-------------#{ buyer_website.inspect unless buyer_website.nil? }"
    
    if !buyer_website.nil?
      ua_number = buyer_website.ua_number
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

  def social_media(permalink, site_type)
    
    media_icons = {
      1 => 'iconFacebook.png',
      2 => 'iconLinkedIn.png',
      3 => 'iconYouTube.png',
      4 => 'iconTwitter.png'
    }
    if site_type == 'seller'
      seller_website = SellerWebsite.find_by_permalink_text(permalink)
      accounts = seller_website.user.social_media_accounts
      site_type_id = 2
    elsif site_type == 'buyer'
      buyer_website = BuyerWebPage.find_by_domain_permalink_text(permalink)
      accounts = buyer_website.my_website.user.social_media_accounts
      site_type_id = 1
    elsif site_type == 'inv_profile'
      accounts = SocialMediaAccount.find(:all, :conditions => {:user_id => permalink, :site_type_id => 1})
      site_type_id = 1
    elsif site_type == 'investor'
      investor_website = InvestorWebsite.find_by_permalink_text(permalink)
      accounts = investor_website.my_website.user.social_media_accounts
      site_type_id = 1
    end
    
    icons = ""
    accounts.each do |account|
      if !account.url.blank? && account.site_type_id == site_type_id
        icons << '<a href=http://'+ account.url.gsub(/\b(.*:\/\/)/,"") + ' target="_blank"><img src="/images/social_media/' + media_icons[account.url_type_id] + '"></a>   '
      end
    end
    return icons
  end

  
  def short_sites(xml_output)
    xml_output_new = Array.new
    i = 7
    xml_output['sites'].collect do |x|
      case x['name']
      when "Trulia"
        xml_output_new[0] = x
      when "Zillow"
        xml_output_new[1] = x
      when "Vast"
        xml_output_new[2] = x
      when "Oodle"
        xml_output_new[3] = x
      when "PropBot"
        xml_output_new[4] = x
      when "Yakaz"
        xml_output_new[5] = x
      when "CLRsearch"
        xml_output_new[6] = x
      else
        xml_output_new[i] = x
        i = i + 1
      end
    end
    xml_output_new.each {|x| puts x['name']}
    xml_output['sites'].each {|x| puts x['name']}
    return xml_output_new
  end
  
  def get_syndication_site_icon(site_name)
    if File.exists?("#{RAILS_ROOT}/public/images/syndication_site_logos/#{site_name}.png")
      return "<img src=\"/images/syndication_site_logos/#{site_name}.png\" alt=#{site_name} width=93 height=24 >"
    else
      return site_name
    end
  end

  def generate_preview_link(profile_summary)
    action = (profile_summary.owner? or profile_summary.seller_agent?) ? 'preview_owner' : 'preview_buyer'
    if @controller.controller_name == 'search'
      return url_for(:controller => 'search', :action => action, :id => profile_summary.id)+"?ref=search&#{encode_return_dashboard_variables}"
    end

    if @profile
      if( params[:controller] == "buyer_websites" || (params[:from] && params[:from] == "buyer_leads"))
        profile_profile_view_path(@profile, profile_summary) + "?own_buyer=#{@own_buyer}&retail_buyer_profile=#{@profile.retail_buyer_profile.id}&#{encode_return_dashboard_variables}"
      else
        profile_profile_view_path(@profile, profile_summary) + "?own_buyer=#{@own_buyer}&#{encode_return_dashboard_variables}"
      end
    else
      url_for(:controller => 'home', :action => action, :id => profile_summary.id, :type => @profile_type.permalink, :zip_code => @zip_code) + "&#{encode_return_dashboard_variables}"
    end
  end

  def random_password_string
    chars = ['A'..'Z', 'a'..'z', '0'..'9'].map{|r|r.to_a}.flatten
    Array.new(8).map{chars[rand(chars.size)]}.join
  end

  def reim_home_feeds feed
    case feed.activity_id
    when 1
      "<p class='text'><strong class='green'> #{feed.user.first_name.humanize}</strong> added a New Buyer Profile in #{feed.territory.reim_name.humanize}</p>"
    when 2
      "<p class='text'><strong class='green'> #{feed.user.first_name.humanize}</strong> added a home for sale in #{feed.territory.reim_name.humanize}</p>"
    when 3
      "<p class='text'><strong class='green'> #{feed.user.first_name.humanize}</strong> sold a property in #{feed.territory.reim_name.humanize}</p>"
    when 4
      "<p class='text'><strong class='green'> #{feed.user.first_name.humanize}</strong> bought a property in #{feed.territory.reim_name.humanize}</p>"
    when 5
      "<p class='text'><strong class='green'> #{feed.user.first_name.humanize}</strong> is talking with a Seller in #{feed.territory.reim_name.humanize}</p>"
    end
  end

  def skip_profile_itration(profile)
    (!profile.profile_delete_reason_id.blank? and profile.profile_delete_reason_id == "other_owner") ? true : false
  end

  def ga_code_for_reim
                                                 ## Used only for REIM internal pages 
    ua_number = ""
    if RAILS_ENV == "production" 
      ua_number = "UA-2786879-8"
    else
      ua_number = "UA-2786879-4"
    end

    ga_code = "var _gaq = _gaq || [];
      _gaq.push(['_setAccount', \'#{ua_number}\']);
      _gaq.push(['_trackPageview']);

     (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();"
    return ga_code    
  end

  def get_clicky_code
    get_clicky = '
<script src="http://static.getclicky.com/js" type="text/javascript"></script>
<script type="text/javascript">try{ clicky.init(66535510); }catch(e){}</script>
<noscript><p><img alt="Clicky" width="1" height="1" src="http://in.getclicky.com/66535510ns.gif" /></p></noscript>
'
    return get_clicky
  end
  
  def is_email_is_bouced_email(email)
    BouncedEmail.find_bounced_email_address(email)
  end

  def profile_contact_name(profile)
    return profile.contact_name.blank? ? "#{profile.user.first_name.to_s + ' ' + profile.user.last_name.to_s}" : profile.contact_name
  end

  def display_contact_phone(profile)
    return "#{profile.contact_phone.blank? ? profile.user.user_company_info.business_phone : profile.contact_phone}" unless profile.user.user_company_info.blank?
  end
  
  def is_user_have_access_to_allinone(user)
    return (user.blank? or user==:false) ? false : (user.map_lah_product_with_user.blank? ? false : (user.map_lah_product_with_user.allinone ? true : false))
  end
end
