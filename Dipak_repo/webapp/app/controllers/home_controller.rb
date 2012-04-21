require 'geoip'

class HomeController < ApplicationController
  before_filter :load_profile_type, :only=>[:preview]
  before_filter :load_target_profile, :only=>[:preview_buyer, :preview_owner]
  before_filter :load_target_profile_nicely, :only=>[:property]

  before_filter :login_required, :only=>["wishtocancel", "update_user_info_when_cancel", "reicancel", "thankyoucancel", "thank_you", "thankyou"]

 
  def index
    @feeds = Feed.find(:all, :order => "id desc", :limit => 14)
    @user = flash[:user] if flash[:user]
    render :layout => 'reim_home'
  end

  def tour
  end

  def support
  end

  def email
    @to_email = "support@reimatcher.com"
    render :action => "email",:layout => false
  end

  def email_to_support
    if request.post?
      @email = SupportEmail.new
      @email.to_email, @email.subject, @email.body = params[:email][:to_email], params[:email][:subject], params[:email][:body]
      if @email.valid?
#         UserNotifier.deliver_send_support_email(@email.to_email, @email.subject, @email.body, current_user.email, current_user.first_name, current_user.last_name)
         Resque.enqueue(SendSupportEmailWorker, @email.to_email, @email.subject, @email.body, current_user.email, current_user.first_name, current_user.last_name)
        @sent = true
        render :action => "email",:layout => false
      else
        render :action => "email",:layout => false
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html"
    end
  end

  def how_it_works
  end

  def feedback
  end

  def pro
    render :layout => false
  end

  def webinar
    render :layout => false
  end

  def sitesdoneforyou
    render :layout => false
  end

  def terms_of_use
  end

#  def wishtocancel
    logger.info"=====its here==="
#  end

  def pro
    render :layout => false
  end

  def update_user_info_when_cancel
    begin
      @user_wish_to_cancel = InvestorCancelHisSubscription.new
      unless params['user_wish_to_cancel'].blank?
        @user_wish_to_cancel.from_hash(params['user_wish_to_cancel'])
        if @user_wish_to_cancel.valid? and params[:user_wish_to_cancel][:understand] == '1'
          user = current_user
          membership_lavel =  user.user_class.user_type_name unless user.user_class.blank?
          user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:basic_type])
          user_cancel_logger=Logger.new("#{RAILS_ROOT}/log/user_cancel_logger.log")
          user_cancel_logger.info "========User Cancels in REIM========\n"
          unless user.blank?
            user_cancel_logger.info "User Class:- #{user.user_class.user_type_name} \n"
            user.is_user_cancel_subscriptn_or_move_with_failed_pay = true
            update_user = user.update_attributes(:user_class_id => user_class.id, :is_user_have_access_to_reim => true, :is_user_cancelled_membership => true, :cancellation_reason => @user_wish_to_cancel.reason, :user_class_before_cancellation=>membership_lavel,:date_of_cancellation=>Time.now)
            Resque.enqueue(UserCancelInReimWorker, user.id, @user_wish_to_cancel.name, @user_wish_to_cancel.reason)
            UserTransactionHistory.create(:user_id => user.id, :transanction_detail => "Customer cancelled membership")
            user_cancel_logger.info "Is user updated:- #{update_user} \n================\n"
          end
          return redirect_to :controller => "home", :action => "reicancel"
        else
          flash[:understand] = 'This checkbox must be checked in order to cancel your membership'
          render :action => :wishtocancel and return
        end
      end
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    return redirect_to :controller => "home", :action => "wishtocancel"
  end

  def reicancel
  end

  def coming_soon
  end

  def privacy
  end

  def contact_us
  end

  def news_updates
    render :layout => 'news_updates'
  end

  def top_uses_seller
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def top_uses_seller_es
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def top_uses_buyer
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def top_uses_buyer_es
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def top_uses_investor
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def top_uses_investor
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def top_uses_investor_es
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end

  def preview
    @territories = (!params[:filter_results].blank? && params[:filter_results][:country] == "CA") ? Territory.find(:all, :conditions => ["country = ? ", "ca"], :order => :territory_name) : []

    @states = @states || State.find(:all, :conditions => ["name is not ?",nil], :order => :name)
    setup_match_criteria(params)
    deleted_at_flag = (params[:id] == "buyer") ? true : false

    # gather messaging stats
    @messaging_stats = MessagingStats.new
    @messaging_stats.fetch_stats

    # gather community stats
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats    

    # initialize filter results 
    @filter_results = FilterResults.new

    # fetch mc_zip_code only when user given search criteria
    if params[:filter_results]
      @filter_results = @filter_results.from_hash(params[:filter_results])
      if !@filter_results.territory_name.blank?
        if !@filter_results.state_name.blank?
          @state_id ||= @filter_results.state_name
          @territories = Territory.find(:all, :conditions => {:state_id => @filter_results.state_name})         
        elsif @filter_results.country == "CA"
          @territories = Territory.find(:all, :conditions => {:country => "ca"})
        end
      end
    end
    
    # Fetch results, with custom pagination support for the bottom area
    @profiles, @total_profiles, @total_pages = MatchingEngine.quick_match(:zip_code => nil, :property_type => @property_type, :profile_type => @profile_type, :offset => @offset, :number_to_fetch => PROFILES_PER_PAGE, :sort => @sort_string, :show_ten_days_deleted_at => deleted_at_flag, :filter_results => (params[:filter_results].blank? ? nil : @filter_results), :allow_duplicate_buyer_profiles => true)

    if @profile_type.buyer?
      @profile_latlngs = profiles_lat_lngs
      @profile_info_windows = profile_info_windows
    end
    
    # Since the test env doesn't have latlngs or zips, we'll force 78728 in test mode
    zip = Zip.find(:first, :conditions => ['zip = ?', @zip_code])
    zip = Zip.find(:first, :conditions => ['zip = ?', '78728']) if zip.nil?
    @center_latlng = zip.latlng
    
    # indicate that we're using popups on thumbnails
    @uses_yui_lightbox = true

    respond_to do |format|
      format.html  do
        if request.xhr?
          render :partial => "preview_results"
        else
          render :action => "preview_results"
        end
        return 
      end
      format.xml   { render :xml => @profiles.to_xml }
      format.json  { render :json => @profiles.to_json(:only => [:id], :methods => [:display_name, :display_type, :display_description, :display_features, :display_price]) }
    end
  end

  def profiles_lat_lngs
    lat_lngs = {}
    @profiles.each do |profile|
      lat_lngs[profile.id] = if profile.latlng && profile.latlng.split(',')[1].to_i < 0
        profile.latlng
      else
        Zip.latlng(profile)
      end
    end
    lat_lngs
  end

  def profile_info_windows
    info_windows = {}
    @profiles.each do |profile|
      info_windows[profile.id] = ZipCodeMap.info_window(profile, nil, encode_return_dashboard_params(@page_number))
    end
    info_windows
  end

  def preview_buyer
     # Needed by message without profile
     @target_profile_type = ProfileType.BUYER
 
    # determine next and prev profile ids
    setup_match_criteria(params)
    # need to fix view before allowing this
    # @prev_profile_id, @next_profile_id, @previous_profile_page, @next_profile_page = find_prev_next_profile_ids(true)
  end

  def property
    render :action=>"preview_owner"
  end

  def preview_owner
    # Needed by message without profile
    @target_profile_type = ProfileType.OWNER
 
    if @target_profile.public_profile?
      # center map on address
      # LATLNG
      center_latlng = @target_profile.owner? ? @target_profile.latlng : nil
      # center_latlng = @target_profile.owner? ? ZipCodeMap.lookup_latlng(@target_profile.geocoder_address) : nil

      if center_latlng == nil then
        @map = ZipCodeMap.prepare_map(@target_profile.zip_code, :suppress_controls => true, :zoom_level => 11, :map_type_init => GMapType::G_HYBRID_MAP )
      else
        @map = ZipCodeMap.prepare_map(@target_profile.zip_code, :suppress_controls => true, :zoom_level => 17, :center_latlng => center_latlng, :map_type_init => GMapType::G_HYBRID_MAP )
        @marker_overlays = ZipCodeMap.prepare_marker_overlays([@target_profile])
      end
    else
      @map = nil
    end
    
    # determine next and prev profile ids
    setup_match_criteria(params)
    # Need to fix view before allowing this
    # @prev_profile_id, @next_profile_id, @previous_profile_page, @next_profile_page = find_prev_next_profile_ids(true)
    
    # indicate that we're using popups on thumbnails
    @uses_yui_lightbox = true
  end

  def single_zip_select
    zip = ZipCodeMap.find_zip_for_coords( params[:lat].to_f, params[:long].to_f )

    render :update do |page|
      page << "zip_selection_controller.change_zipcodes('" + zip.zip + "');"
      page << "preview_results_controller.updateProfileMatches();"
    end
  end

  def multi_zip_select
    zip = ZipCodeMap.find_zip_for_coords( params[:lat].to_f, params[:long].to_f ).zip
    ziplist = params[:zipcodes]

    # check to see if list already contains zip
    if ziplist.include? zip then
      # don't remove last zip
      if ziplist.include? ',' then
        # remove from list
        zipset = ziplist.split(/,\s*/)
        ziplist = ''

        zipset.each do |z|
          unless z.include? zip then
            ziplist += ',' unless ziplist.size == 0
            ziplist += z
          end
        end
      end
    else
      # add to list
      ziplist = params[:zipcodes] + ',' + zip
    end

    render :update do |page|
      page << "zip_selection_controller.change_zipcodes('" + ziplist + "');"
      page << "preview_results_controller.updateProfileMatches();"
    end
  end
  
  def show_image
    @image_url = "/images/#{params[:id]}.#{params[:format]}"
    render :layout=>"application"
  end
  
  def setup_match_criteria(params)
    # use ip address to guess location
    geoip = GeoIP.new( RAILS_ROOT + '/public/geoip/GeoLiteCity.dat' ).city( self.request.remote_ip )
    geoip_zip_code = geoip[ 8 ] unless geoip.nil?
    geoip_zip_code = '78701' if geoip_zip_code.nil?
    
    @zip_code = params[:zip_code] || geoip_zip_code
    @page_number = (params[:page_number] || "1").to_i
    @page_number = 1 if @page_number == 0 #  || (@page_number.kind_of? String && @page_number.blank?)
    @offset = @page_number == 1 ? nil : (@page_number-1) * PROFILES_PER_PAGE
    @property_type = params[:property_type] || "all"
    @property_type = "all" if @property_type.empty?
    @profile_type = ProfileType.find_by_permalink(params[:type]) if @profile_type.nil?
    return if @profile_type.nil?

    @sort = params[:sort]
    if @sort.blank?
      @sort = @profile_type.owner? ? "has_profile_image,desc" : "privacy,desc"
    end
    @sort_type = @sort.split(',')[0]
    @sort_order = @sort.split(',')[1]
    @sort_string = "#{@sort_type} #{@sort_order}"
  end
  
  def send_mail
    user_info = "User Not Logged In!"
    if current_user != :false
      user_info = current_user.full_name unless current_user.blank?
    end
    UserNotifier.deliver_send_error_notification(params.merge({:user_info => user_info}))
    flash[:notice] = "Thanks for your feedback, We'll take a look shortly."
    redirect_to '/'
  end

# Filter Results section at /home/preview/buyer: Populate territories dropdown for selected state
  def get_territories_for_fr
    if request.xhr?
      state_id = params[:state_id]
      @territories = Territory.find(:all, :conditions=>["state_id = ? ", state_id],:order=>:territory_name)
      render :layout=>false
    else
      render :text=>"Bad Request" ,:layout=>false
    end
  end

  def lpo_1
    render :layout => false
  end

   def update_preview_territory
      if !params[:country_id].blank? and params[:country_id] == "CA" 
        @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
        render :partial => 'update_canada_territory_for_preview'        
      else
        @territories = Array.new
        @states = State.find(:all,:conditions => ["name is not null and country = ?",params[:country_id]], :order=>:name)
        render :partial => 'update_us_territory_for_preview'        
      end 
  end
   
   def thankyoucancel
     begin
       syndicator_listing
       site_array = []
       @xml_output['sites'].each{|site| site_array << site['id']}
       profiles = current_user.profiles.property_profiles
       profiles.each do |profile|
         SyndicateProperty.save_manual_syndicate_property(profile.id, profile.user_id)
         ps_array = ProfileSite.find_all_by_profile_id(profile.id, :select => :site_id).collect! {|ps| ps.site_id}
         ProfileSite.update_all("syndicated = false, updated_at = '#{Time.now.to_formatted_s(:db)}'", "profile_id = '#{profile.id}' and site_id in (#{site_array * ', '})") if !site_array.blank?
         diff  = ps_array - site_array
         ProfileSite.update_all("syndicated = true, updated_at = '#{Time.now.to_formatted_s(:db)}'", "profile_id = '#{profile.id}' and site_id in (#{diff * ', '})") if !diff.blank?
       end
       SiteUser.delete_all(:user_id => current_user.id)
     rescue  Exception => exp
       ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
     end
   end
 end