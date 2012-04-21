# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthenticatedSystem
  include ExceptionLoggable
  require 'smpt_api_header.rb'
  # Pick a unique cookie name to distinguish our session data from others'
  #session :session_key => '_nl_session_id'

  before_filter :authorize
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # contest invite support
  before_filter :check_for_contest_invite_url

  PROFILES_PER_PAGE = 10

  def authorize(realm='PROTO_design', errormessage="Could't authenticate you")
    # enforce only in production
    if !staging?
      return true
    end

    # skip for internal pages - the user has created an account by now
    if self.controller_name != 'home'
      return true
    end

    username, passwd = get_auth_data
    # check if authorized
    # try to get user
    if username == 'proto' and passwd == 'type'
      return true
    else
      # the user does not exist or the password was wrong
      response.headers["Status"] = "Unauthorized"
      response.headers["WWW-Authenticate"] = "Basic realm=\"#{realm}\""
      render :text => errormessage, :status => 401 and return false
    end
  end

  def check_zip
    if (params[:country] == 'CA' && params.has_key?('zip_code'))
      flash[:notice] = "Please choose appropriate Country"
      redirect_to "buyer_websites/edit_buying_areas/#{params[:id]}"
      flash[:notice] = "Please choose appropriate Country"
      return false
    elsif (params[:country] == 'US' && params.has_key?('city'))
      flash[:notice] = "Please choose appropriate Country"
      redirect_to "buyer_websites/edit_buying_areas/#{params[:id]}"
      flash[:notice] = "Please choose appropriate Country"
      return false
    elsif (params[:country] == 'US')
      if params[:wholesale].blank? and !params[:owner_finance].blank?
        zips = params[:zip_code].scan(/\w+\s*\w*/)
        zips.each do |i|
          j = Zip.find_by_zip(i)
          if j.nil?
            flash[:notice] = "Please choose appropriate Zip Code" 
            #return false
            redirect_to "buyer_websites/edit_buying_areas/#{params[:id]}"
            flash[:notice] = "Please choose appropriate Zip Code" 
            return false
          end
        end
      else
        if params[:county].blank? or params[:county][:county].blank?
          flash[:notice] = "Please choose appropriate Zip Code" 
          #return false
          redirect_to "buyer_websites/edit_buying_areas/#{params[:id]}"
          flash[:notice] = "Please choose appropriate Zip Code" 
          return false
        else 
          next_flag = false
          params[:county][:county].each do |coun|
            pro_coun = County.find(:first, :conditions => ["name = ?",coun])
            next if pro_coun.blank?
            pro_zip = Zip.find(:first, :conditions => ["county_id = ?",pro_coun.id])
            next if pro_zip.blank?
            params[:zip_code], next_flag = pro_zip.zip, true
            break 
          end
          unless next_flag
            flash[:notice] = "Please choose appropriate Zip Code" 
            #return false
            redirect_to "buyer_websites/edit_buying_areas/#{params[:id]}"
            flash[:notice] = "Please choose appropriate Zip Code" 
            return false
          end
        end
      end
      return true    
    end
  end

  private

  def syndicator_listing
    uri = URI.parse(SYNDICATION_URL + "sites_listing")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(SYND_APP['login'], SYND_APP['password'])
    response = http.request(request)

    @xml_output = Crack::XML.parse(response.body)
    @xml_output.each{|k,v| v.delete_if{|a| a["name"] == "Oodle Pro"}} if current_user.user_class.user_type_name != "Pro"
  end

  def get_auth_data
    user, pass = '', ''
    # extract authorisation credentials
    if request.env.has_key? 'X-HTTP_AUTHORIZATION'
      # try to get it where mod_rewrite might have put it
      authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split
    elsif request.env.has_key? 'Authorization'
      # for Apace/mod_fastcgi with -pass-header Authorization
      authdata = request.env['Authorization'].to_s.split
    elsif request.env.has_key? 'HTTP_AUTHORIZATION'
      # this is the regular location
      authdata = request.env['HTTP_AUTHORIZATION'].to_s.split
    elsif request.env.has_key? 'Authorization'
      # this is the regular location, for Apache 2
      authdata = @request.env['Authorization'].to_s.split
    end

    # at the moment we only support basic authentication
    if authdata and authdata[0] == 'Basic'
      user, pass = Base64.decode64(authdata[1]).split(':')[0..1]
    end
    return [user, pass]
  end  
      
  def local_request?
    false
  end 

  protected

  def secrete_key_required
    if !params[:key].blank? and params[:key] == REIM_WP_SECRETE_KEY
      return true
    else
      render :json => {"00k" => "Secrete key is not valid"}
    end
  end

  def load_optional_profile
    if params[:id] or params[:profile_id]
      @profile = Profile.find_by_id(params[:profile_id] || params[:id])
    end
  end
  
  def load_profile_type
    prof_id = params[:id] || params[:property_id]
    if(prof_id)
      @profile_type = ProfileType.find_by_permalink(prof_id) rescue nil
      return true if @profile_type
    else
      handle_error "Must supply a profile type id" and return false
    end

    handle_error "Must supply a valid profile type id" and return false
  end

  def load_profile
    # It was either do this or add a whole new set of routes for messaging without a profile
    if params[:id] == 'ask' || params[:profile_id] == 'ask'
      return
    end

    if(params[:id] or params[:profile_id])
      @profile = Profile.find_by_id(params[:profile_id] || params[:id]) rescue nil
      if @profile.nil?
        handle_error "This profile no longer exists" and return false
      end
      @profile_type = @profile.profile_type
      return true if @profile
    else
      handle_error "Must supply a profile id" and return false
    end

    handle_error "Must supply a valid profile id" and return false
  end

  def load_target_profile
    if(params[:id])
      @target_profile = Profile.find_by_id(params[:id])
      # support permalink lookup for SEO goodness
      @target_profile = Profile.find_by_permalink(params[:id]) if @target_profile.nil?
      @target_profile = Profile.find_by_random_string(params[:id]) if @target_profile.nil?

      if @target_profile.nil?
        handle_error "This profile could not be found or no longer exists" and return false
      end
      @target_profile_type = @target_profile.profile_type
      return true if @target_profile
    else
      handle_error "Must supply a target profile id" and return false
    end

    handle_error "Must supply a valid target profile id" and return false
  end

  def load_target_profile_nicely
    if(params[:id])
      @target_profile = Profile.find_by_id(params[:id])
      # support permalink lookup for SEO goodness
      @target_profile = Profile.find_by_permalink(params[:id]) if @target_profile.nil?

      if @target_profile.nil?
        # issue a 301 to the property lens page
        head :moved_permanently, :location => url_for(:controller=>'home', :action=>'index')
        return false
      end
      @target_profile_type = @target_profile.profile_type
      return true if @target_profile
    else
      handle_error "Must supply a target profile id" and return false
    end

    handle_error "Must supply a valid target profile id" and return false
  end

  def check_profile_ownership
    if params[:id] == 'ask' || params[:profile_id] == 'ask'
      return
    end
    user = current_user
    if @profile and user.kind_of?(User)
      if @profile.user_id == user.id
        return true
      end
    end

    handle_error "Sorry, but the profile you requested isn't owned by you. Please sign-in as the proper owner to manage this profile" and return false
  end

  def load_ad
    if(params[:id])
      @ad = Ad.find_by_id(params[:id]) rescue nil
      return true if @ad
    else
      handle_error "Must supply an ad id" and return false
    end

    handle_error "Must supply a valid ad id" and return false
  end

  def production_mode
    return production_mode?
  end

  def handle_error(text,e=nil)
    if e.nil?
      render :text=>text, :status=>500
    else
      render :text=>text+" Details:#{e.to_s}", :status=>500
    end
  end

  def check_for_contest_invite_url
    if params[:utm_medium] == 'contest'
      # we have a requested URL that contains details about a contest invitation
      campaign_code = params[:utm_campaign]
      name_plus_email = params[:utm_source]
      to_email = params[:to_email]
      first_visited_url = request.path
      if campaign_code and name_plus_email and to_email
        # found everything we need - let's try to process
        ContestInvitation.connection.update("UPDATE contest_invitations SET first_visited_url = '#{first_visited_url}', accepted_at = now() WHERE campaign_code = '#{campaign_code}' AND first_visited_url IS NULL AND to_email = '#{to_email}'" )
      end
    end

    # always allow the request to proceed
    return true
  end
  
  def find_prev_next_profile_ids(params, quick = false)
    curr_index = -1
    sort = params[:sort]
    params[:page_number] = 1 if params[:page_number].blank?
    sort = sort.gsub(/,/, ' ') if sort
    offset = 0
    offset = (params[:page_number].to_i-1)*PROFILES_PER_PAGE if params[:page_number]
    # Start one before our current position in case we're on the last entry on a page
    offset -= 1 unless offset == 0
    # Add two - one for if we're on the first of a page, another for if we're on the last
    number_to_fetch = PROFILES_PER_PAGE
    number_to_fetch += 2
    
    if quick then
      profile_ids, count, total_pages = MatchingEngine.quick_match(:zip_code=>nil, :property_type=>@property_type, 
          :profile_type=>@profile_type, :offset=>offset, :number_to_fetch=>number_to_fetch, :sort=>@sort_string,
          :listing_type=>params[:listing_type])
    else
      exact_profile_ids, exact_count, exact_total_pages = MatchingEngine.get_matches(:profile=>@profile, :mode=>:ids,
          :offset=>offset, :result_filter=>params[:result_filter], :number_to_fetch=>number_to_fetch, 
          :sort=>sort, :listing_type=>params[:listing_type], :use_cache => true)
      #Near Match
      if (@profile.is_wholesale_profile? or @profile.is_wholesale_owner_finance_profile?)
        near_profiles,near_total_profiles,near_total_pages = [], 0, 0
      else
        near_offset,near_number_to_fetch = Profile.get_limit_and_offset(exact_count,params[:page_number].to_i,PROFILES_PER_PAGE)
        near_profiles,near_total_profiles,near_total_pages = MatchingEngine.get_matches(:profile=>@profile, :mode=>:ids, :offset=>near_offset, :result_filter=>params[:result_filter], :number_to_fetch=> number_to_fetch, :sort=>sort, :listing_type=>params[:listing_type], :use_cache => true, :near_match => true)
      end
        count = exact_count + near_total_profiles
        profile_ids = exact_profile_ids + near_profiles
    end

    profile_ids.each_with_index { |profile_id,index| curr_index = index if profile_id == @target_profile.id }
    if curr_index > 0
      @prev_profile_id = profile_ids[curr_index-1]
      previous_profile_page = ((offset+curr_index-1)/PROFILES_PER_PAGE)+1
    end
    if curr_index < count-1
      @next_profile_id = profile_ids[curr_index+1]
      next_profile_page = ((offset+curr_index+1)/PROFILES_PER_PAGE)+1
    end
    return @prev_profile_id, @next_profile_id, previous_profile_page, next_profile_page
  end

  def admin_access_required
    if current_user == :false
      redirect_to :controller => 'sessions', :action => 'new'
    else
      redirect_to :controller=>:account,:action=>:profiles if !current_user.admin?
    end
  end

end