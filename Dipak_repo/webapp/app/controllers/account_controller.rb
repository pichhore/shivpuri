class AccountController < ApplicationController

  before_filter :login_required, :only=>["profiles", "settings", "digest_frequency", "company_info", "profile_image", "marketing","update_profile_image","welcome","step1","step2","step3", "territory_selection", "save_user_territory", "get_territories", "get_territory_name", "get_counties","investor_directory_page","investor_conversation","investor_inbox","send_message_to_investor","delete_investor_inbox_message", "investor_full_page","profile_inbox","delete_profile_inbox_message","get_feeds", "add_buyer_created", "syndicate", "save_preferences", "social_media", "save_social_media_accounts", "facebook","fb_reconnect","fb_callback","show_deals","update_deal","manage_deal"]


  uses_yui_editor(:only => ["marketing","update_marketing_page"])

  #before_filter :check_investor_role, :only=>["buyer_webpage","marketing","investor_inbox","investor_directory_page","profile_inbox","delete_user_territory","save_buyer_web_page","territory_selection","digest_frequency","update_marketing_page","territory_helper","send_message_to_investor","get_feeds"]

   before_filter :only=>["marketing","territory_selection","update_marketing_page"] do  |controller|
    controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc1_type],BASIC_USER_CLASS[:uc2_type]])
  end


  PROPERTIES_PER_PAGE = "5"
   
  def add_buyer_created
    profiles
    render :action=>"profiles"
  end
  
  def add_owner_created
    profiles
    render :action=>"profiles"
  end
  
  def syndicate
    @user_subscription = current_user.user_class.user_type_name
    @site_users = SiteUser.find_all_by_user_id(current_user.id, :select => 'site_users.site_id, site_users.id')
    uri = URI.parse(SYNDICATION_URL + "sites_listing")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(SYND_APP['login'], SYND_APP['password'])
    @response = http.request(request)

    @xml_output = Crack::XML.parse(@response.body)
    unless @xml_output["sites"].empty?
      @xml_output["sites"].index{|x| x["name"] == "Oodle"}
      @xml_output["sites"].insert(@xml_output["sites"].length-1, @xml_output["sites"].delete_at(@xml_output["sites"].index{|x| x["name"] == "Oodle"})) 
    end
  end
  
  def save_preferences    
    @user = current_user
    @user.update_attributes({:auto_syndication => (params['automatic'] == "1" ? true : false)})
    @site_users = SiteUser.find_all_by_user_id(current_user.id, :select => 'site_users.site_id, site_users.id')
    sites_array = Array.new
    
    @site_users.each do |site_user|
      
      sites_array << site_user.site_id.to_s
      if !params[:sites].nil? && !params[:sites].has_value?(site_user.site_id.to_s)
        SiteUser.destroy(site_user.id)
      elsif params[:sites].nil?
        SiteUser.destroy(site_user.id)
      end
    end
    
    if !params[:sites].nil?
      params[:sites].each do |k,v|
        SiteUser.add(current_user.id, v) if !sites_array.include?(v)
      end
    end
    redirect_to :back
  end
  
  def profiles
    # render the list of profiles for the user, sort with the newest at the top
    # Ticket #386 - no longer go to the user's only profile automatically anymore
    # @profiles = current_user.profiles.find(:all, :order=>"created_at DESC")

    template = ""
    conditions = []
    keyword = params[:user_profiles_search]
    if !keyword.nil? && keyword != ""
      query_string = keyword.gsub(/[\'|\"|\.]/, '')
      search = ActsAsXapian::Search.new([Profile], query_string, {:limit=>10000000})
      keyword_profiles = []
      search.results.each { |result|
        keyword_profiles << result[:model]
      }
      query_like_string = "%#{keyword.to_s.gsub(/[\'|\"|\.]/, '')}%"
      template << " profiles.name like ? || profiles.private_display_name like ? "
      conditions[0] = template
      conditions.push(query_like_string)
      conditions.push(query_like_string)
      if !keyword_profiles.empty?
        template << " || (profile_field_engine_indices.profile_id in (?)) " 
        conditions[0] = template
        conditions.push(keyword_profiles)
      end
    end
    @profiles = current_user.profiles.paginate(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id and status='active' and profiles.deleted_at IS NULL " , :conditions => conditions, :order=>"created_at DESC", :group => "permalink", :page => params[:page])
    @user = current_user
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
    @user.active_alerts(force_reload=true).each_with_index do |alert, idx|
      @welcome_alert = alert if alert.alert_definition.is_welcome_alert == true
      @welcome_alert_active = alert if @welcome_alert and (alert.alert_definition.welcome_alert_expiry.to_i > (Time.now - @user.activated_at)/(60*60*24))
      break if @welcome_alert_active
    end
    @completeness, @todos = @user.profile_completeness_with_todos
  end
  
  def welcome
    @user = current_user
    render :layout => "welcome"
  end
  
  def step1
    @user = current_user
    @investor_type_cb = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'CB')
    @investor_type_pl = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'PL')
    @investor_type_la = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'LA')
    render :layout => "welcome"
  end
  
  def step2
    @user = current_user
    company_info
    render :layout => "welcome"
  end
  
  def step3
    @user = current_user
    render :layout => "welcome"
  end

 def set_investor_type
    @investor_type1 = InvestorType.new
      unless params[:cash_buyer].blank? 
         investor_type_exist1 = InvestorType.find_by_user_id_and_investor_type(current_user.id, "CB")
        @investor_type1.update_attributes(:user_id => current_user.id, :investor_type => "CB") if investor_type_exist1.nil?
      else
        @investor_type1 = InvestorType.find_by_user_id_and_investor_type(current_user.id, "CB")
        @investor_type1.destroy unless @investor_type1.nil?
      end
    @investor_type2 = InvestorType.new
      unless params[:private_lender].blank? 
         investor_type_exist2 = InvestorType.find_by_user_id_and_investor_type(current_user.id, "PL")
        @investor_type2.update_attributes(:user_id => current_user.id, :investor_type => "PL") if investor_type_exist2.nil?
      else
        @investor_type2 = InvestorType.find_by_user_id_and_investor_type(current_user.id, "PL")
        @investor_type2.destroy unless @investor_type2.nil?
      end
    @investor_type3 = InvestorType.new
      unless params[:licened_agent].blank? 
         investor_type_exist3 = InvestorType.find_by_user_id_and_investor_type(current_user.id, "LA")
        @investor_type3.update_attributes(:user_id => current_user.id, :investor_type => "LA") if investor_type_exist3.nil?
      else
        @investor_type3 = InvestorType.find_by_user_id_and_investor_type(current_user.id, "LA")
        @investor_type3.destroy unless @investor_type3.nil?
      end
      @investor_type_cb = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'CB')
      @investor_type_pl = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'PL')
      @investor_type_la = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'LA')
  end  

  def upload_investor_image(retrun_flag = true)
      @buyer_user_image = BuyerUserImage.new(params[:buyer_user_image])
      @buyer_user_image.user_id = current_user.id
        if @buyer_user_image.valid?
              buyer_user_image = BuyerUserImage.find(:all, :conditions=>[" user_id = ? ",current_user.id])
              if buyer_user_image.size > 0
                old_buyer_user_image = BuyerUserImage.find(buyer_user_image[0].id)
                old_buyer_user_image.destroy
              end
              @buyer_user_image.save!
              flash.now[:notice] = "Image upload successfully."
              image_path = !@buyer_user_image.blank? ? ( !@buyer_user_image.find_medium_thumbnail.blank? ? @buyer_user_image.public_filename(:medium) : nil) : nil
              image_path = REIMATCHER_URL.chop + image_path if !image_path.blank?
              UserForumIntegration.update_profile_picture_on_other_products(current_user.login, image_path.to_s)  if RAILS_ENV == "production"
 
              return retrun_flag
        else
              @buyer_user_image = BuyerUserImage.find_buyer_profile_image(current_user.id)
              flash.now[:notice] = "Invalid image format. Please check that the image is one of the support types and , it is under 3MB in size."
              return false
        end
  end
  
  def settings
    @investor_type_cb = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'CB')
    @investor_type_pl = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'PL')
    @investor_type_la = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'LA')
    @buyer_user_image = BuyerUserImage.find_buyer_profile_image(current_user.id)
    @user = current_user
    if request.post? && params[:commit] == "Upload Image"
      upload_investor_image
      return
    end
    if request.post?
      begin
        if params['change_password'] and !params['change_password'].empty?
          if (params['change_password'] == params['change_password_confirmation'])
            @user.change_password(params['change_password'], params['change_password_confirmation'])
            @password_changed = true
          else
            flash[:error] = "Password and password confirmation do not match"
            return
          end
        end
        unless params[:buyer_user_image].nil? || params[:buyer_user_image][:uploaded_data].blank?
          return if upload_investor_image(false)
        end
        @user.update_attributes(params['user'])
          if @user.save
          set_investor_type
          begin
             #~ #send the email
            #sending change password email through Resque
            if !params[:user_focus_investor].blank?
               params[:user_focus_investor][:is_wholesale] = "0" if params[:user_focus_investor][:is_wholesale].blank?
               params[:user_focus_investor][:is_fix_and_flip] = "0" if params[:user_focus_investor][:is_fix_and_flip].blank?
               params[:user_focus_investor][:is_longterm_hold] = "0" if params[:user_focus_investor][:is_longterm_hold].blank?
               params[:user_focus_investor][:is_lines_and_notes] = "0" if params[:user_focus_investor][:is_lines_and_notes].blank?
               if !@user.user_focus_investor.blank?
                user_focus_investor = UserFocusInvestor.find_by_id(@user.user_focus_investor.id)
                user_focus_investor.update_attributes(params[:user_focus_investor])
               else
                user_focus_investor = UserFocusInvestor.new(params[:user_focus_investor])
                user_focus_investor.save!
               end
            end
            Resque.enqueue(ChangePasswordNotificationWorker, @user.id, params['user']['password'] ) if @password_changed
          rescue Exception => exp
            ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
          end
          flash[:notice] = "Settings have been updated"
          flash[:notice] += ". An email has been sent with your new password." if @password_changed
          redirect_to :action => 'settings'
        else
	  @investor_type_cb = params[:cash_buyer]
	  @investor_type_pl = params[:private_lender]
	  @investor_type_la = params[:licened_agent]
        end
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error trying to update your settings. Please try again later or contact support",exp) and return
      end
    end
  end
  
  def digest_frequency
    @user = current_user
    
    if request.post?
      @user.update_attributes(params["user"])
      begin
        @user.save
        flash[:notice] = "Your email subscriptions have been updated"
        redirect_to :action => 'digest_frequency' and return
      rescue Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error trying to update your email subscriptions. Please try again later or contact support",exp) and return
      end
    end
    
  end
  
  def company_info
    begin
      @user_company_image = UserCompanyImage.find_company_profile_image(current_user.id)
      if request.post?   
        temp_business_array = Array.new
        temp_business_array = [params[:user_company_info][:business_name],params[:user_company_info][:business_address],params[:user_company_info][:business_phone],params[:user_company_info][:business_email], params[:user_company_info][:city],params[:user_company_info][:state],params[:user_company_info][:zipcode],params[:user_company_info][:country]]
        session[:business_params] = temp_business_array
        if params[:commit] == "Upload Image" and params[:check_enter] == "0"
          if !params[:user_company_image][:uploaded_data].blank?
            prev_user_company_image = UserCompanyImage.find_by_user_id(current_user.id) 
            prev_user_company_image.destroy if prev_user_company_image
            @user_company_image = UserCompanyImage.new(params[:user_company_image])
            @user_company_image.user_id = current_user.id
            if @user_company_image.save
              flash[:notice] = "Image upload successful."
              unless params[:temp] == 'step2'
                redirect_to :action => 'company_info', :controller=>:account and return 
              else
                redirect_to :action => 'step2', :controller=>:account and return
              end
            else
              flash[:error] = "Invalid image format. Please check that the image is one of the support types and , it is under 3MB in size."
              unless params[:temp] == 'step2'
                redirect_to :action => 'company_info', :controller=>:account and return
              else
                redirect_to :action => 'step2', :controller=>:account and return
              end
            end
          else
              flash[:error] = "Please select Image"
              unless params[:temp] == 'step2'
                redirect_to :action => 'company_info', :controller=>:account and return
              else
                redirect_to :action => 'step2', :controller=>:account and return
              end
          end
        elsif params[:commit] == "Update Settings" or params[:commit] == "Next" or params[:check_enter] == "1"
          unless params[:commit] == 'Next'
            prev_user_company_image = UserCompanyImage.find_by_user_id(current_user.id)
            if !params[:user_company_image][:uploaded_data].blank?
              prev_user_company_image.destroy if prev_user_company_image
              @user_company_image = UserCompanyImage.new(params[:user_company_image])
              @user_company_image.user_id = current_user.id
              if !(@user_company_image.save)
                flash[:error] = "Invalid image format. Please check that the image is one of the support types and , it is under 3MB in size."
                unless params[:temp] == 'step2'
                  redirect_to :action => 'company_info', :controller=>:account and return
                else
                  redirect_to :action => 'step2', :controller=>:account and return
                end
              end
#             elsif prev_user_company_image.nil?
#               flash[:error] = "Please select image"
#               redirect_to :action => 'company_info', :controller=>:account and return
            end
          end          
          @user_company_info = UserCompanyInfo.find_by_user_id(current_user.id) || UserCompanyInfo.new
          @user_company_info.business_name = params[:user_company_info][:business_name]
          @user_company_info.business_address = params[:user_company_info][:business_address]
          @user_company_info.business_phone = params[:user_company_info][:business_phone]
          @user_company_info.business_email = params[:user_company_info][:business_email]
          @user_company_info.city = params[:user_company_info][:city]
          @user_company_info.country = params[:user_company_info][:country]
          @user_company_info.state = params[:user_company_info][:state]
          @user_company_info.zipcode = params[:user_company_info][:zipcode]
          @user_company_info.user_id = current_user.id
          
          if @user_company_info.business_phone.blank?
            if params[:temp] == 'step2'
              flash[:business_phone] = "can't be blank"
              redirect_to :action => 'step2', :controller=>:account and return
            end
          end
          
          if @user_company_info.business_email.blank?
            if params[:temp] == 'step2'
              flash[:business_email] = "can't be blank"
              redirect_to :action => 'step2', :controller=>:account and return
            end
          end
          
          begin
            if @user_company_info.save(if params[:temp] == "step2" then false else true end)              
              unless params[:temp] == 'step2'
                flash[:notice] = "Company info saved successfully."
                flash[:notice] = "Company info saved successfully. but company logo is required" if prev_user_company_image.nil?
                redirect_to :action => 'company_info', :controller=>:account and return 
              else
                redirect_to :action => 'step3', :controller=>:account and return 
              end
#            else
#              if params[:action] == 'step2'
#                redirect_to :action => 'step2', :controller=>:account and return
#              else
#                redirect_to :action => 'company_info', :controller=>:account and return
#              end
            end
          rescue  Exception => exp
            ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
            handle_error("Error trying to update your settings. Please try again later or contact support",exp) and return
          end  
        end
      end
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Error trying to update your email subscriptions. Please try again later or contact support",exp) and return
    end
  end
  
  def dashboard
    if !params[:user].nil?
      if params[:user][:terms_of_use] == '1'
        @user = current_user
        @user.update_attributes({:user_status => 'Terms Accepted', :tou_accepted_at => Time.now})
        redirect_to :action => :profiles
      else
        flash[:terms] = 'You must agree to the terms of use'
        redirect_to :action => :step3
      end
    else
      redirect_to :action => :profiles
    end
  end
  
  def update_business_phone
    @user = User.find_by_id(current_user.id)
    if !params[:user].nil? && !@user.blank?
    if @user.update_attribute(:business_phone, params[:user][:business_phone])
      flash[:notice] = "Cell phone info saved successfully."
      redirect_to :action => 'step1', :controller=>:account and return 
    end
    else
      render :file => REI_404_PAGE
    end
  rescue Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    render :file => REI_404_PAGE
  end
    
  def forgot_password
    if request.post?
      if !params["email"] || params["email"].empty?
        flash.now[:error] = "Email is required" and render :layout=>"login_ui" and return
      end
      
      @user = User.find_by_login(params["email"])
      if !@user
        flash.now[:error] = "Email address not found" and render :layout=>"login_ui" and return
      end
      
      begin
        key = @user.generate_security_token
        url = url_for(:controller=>"account",:action => 'change_password')
        url += "/#{@user.id}?key=#{key}"
	   #~ #send the email
        #sending email through Resque
       Resque.enqueue(ForgotPasswordNotificationWorker, @user.id, url)
        flash[:notice] = "Instructions for resetting your password have been emailed to "+@user.email
        redirect_to :controller=>"sessions", :action => 'new'
        rescue Exception => exp
          ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
          handle_error("Error trying to process password change. Please try again later or contact support.",exp) and return
        end
    else
      render :layout=>"login_ui"
    end
  end
  
  def change_password
    if params["id"] && params["key"]
      begin
        @user = User.authenticate_by_token(params["id"], params["key"])
        if !@user
          handle_error("This link has expired. Go to the forgotten password page to request another password change.") and return
        end
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("User not found with id=#{params["id"]} and key=#{params["key"]} "+exp.to_s) and return
      end
    elsif logged_in?
      @user = current_user
    else
      handle_error("Id and Key are required") and return
    end
    
    if request.get?
      # reset before redisplaying
      @user.password = nil
      @user.password_confirmation = nil
    else
      begin
        @user.change_password(params['user']['password'], params['user']['password_confirmation'])
        if @user.save
		#~ #send the email
          #sending change password email through Resque
          Resque.enqueue(ChangePasswordNotificationWorker, @user.id, params['user']['password'] )
          flash[:notice] = "Password changed. An email has been sent confirming the new password"
          # sysadmin case
          redirect_to :controller=>'/admin/admin_users', :action => 'index' and return if logged_in? and (current_user.id != @user.id)
          # logged in, changing own password case
          redirect_to :action => 'settings' and return if logged_in?
          # not logged in, changing own password case
          redirect_to :controller=> 'sessions', :action => 'new' and return
        end
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error trying to change password. Please try again later or contact support",exp) and return
      end
    end
    # reset before redisplaying
    @user.password = nil
    @user.password_confirmation = nil
  end
  
  def marketing
    @user_company_image = UserCompanyImage.find_by_user_id(current_user.id)
    case params[:commit]
      when "Preview"
      render :partial => "preview", :layout => true and return
      else
      if request.post?
        @buyer_notification = BuyerNotification.find(:first,:conditions => ["user_id = ? and summary_type LIKE ?",current_user.id,params[:buyer_notification][:summary_type]])
        if @buyer_notification.nil?
          @buyer_notification = BuyerNotification.new(params[:buyer_notification])
          @buyer_notification.user_id = current_user.id
          if @buyer_notification.save!
            flash.now[:notice] = "Notification settings has been updated successfully."
            get_paragraph_marketing(@buyer_notification.summary_type)
            render :action => "marketing"
          end
        else
          @buyer_notification.update_attributes(params[:buyer_notification])
          flash.now[:notice] = "Notification settings has been updated successfully."
          get_paragraph_marketing(@buyer_notification.summary_type)
          render :action => "marketing"
        end
      else
        get_paragraph_marketing('welcome')
      end
    end
  end

  def update_marketing_page
     get_paragraph_marketing(params[:id])
     render :partial => "marketing", :locals => {:id => params[:id]}  
  end
  
  def profile_image
    @investor_type_cb = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'CB')
    @investor_type_pl = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'PL')
    @investor_type_la = InvestorType.find_by_user_id_and_investor_type(current_user.id, 'LA')
  end
  
  def update_profile_image    
    @investor_type = InvestorType.new
    
    if params[:inv_type]      
      case params[:inv_type]
        when 'CB'
          profile_inv = params[:cash_buyer]
        when 'PL'
          profile_inv = params[:private_lender]
        when 'LA'
          profile_inv = params[:licened_agent]
      end
      
      unless profile_inv.blank? 
        update_investor_type(current_user.id, params['inv_type'],params[:from])
      else
        delete_investor_type(current_user.id, params['inv_type'],params[:from])
      end
    end
  end
  
  def delete_investor_type(user_id, investor_type, from)
     @investor_type = InvestorType.find_by_user_id_and_investor_type(current_user.id, investor_type)
     if !@investor_type.nil? && @investor_type.destroy
       flash[:notice] = "Investor profile updated successfully"
       if from == 'step1'
         redirect_to :action => 'step1', :controller=>:account and return
       else
         redirect_to :action => 'profile_image', :controller=>:account and return
       end       
     end
  end
  
  def update_investor_type(user_id, investor_type, from)
     if @investor_type.update_attributes(:user_id => user_id, :investor_type => investor_type)
       flash[:notice] = "Investor profile updated successfully"
      if from == 'step1'
         redirect_to :action => 'step1', :controller=>:account and return
       else
         redirect_to :action => 'profile_image', :controller=>:account and return
       end   
     end  
  end

  def territory_selection
    @user_territories = current_user.user_territories.find(:all,:order=>"sequeeze_page_number")
    @max_no_of_territories = current_user.number_of_territory.blank? ? 3 : current_user.number_of_territory.to_i
    redirect_to :action=>:buyer_webpage if @user_territories.size > ( @max_no_of_territories - 1 )
    @user_territory = UserTerritory.new
    @territories = Array.new
    @states = State.find(:all,:conditions => ["name is not null"], :order=>:name)
    # @states = State.find(:all,:order=>:state_code)
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end
  
  def get_counties
    if request.xhr?
      state_id = params[:state_id]
      @counties = County.get_counties_for_state(state_id)
      render :layout=>false
    else
      render :text=>"Bad Request" ,:layout=>false
    end    
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :text=>"Bad Request" ,:layout=>false
  end

  def get_territory_name
    if request.xhr?
      @state = State.find_by_id( params[:state_id] )
      @county = County.find_by_id( params[:county_id] )
      @territories = Territory.get_territories_for_county_and_state( @county.id, @state.id )
      render :layout=>false
    else
      render :text=>"Bad Request" ,:layout=>false
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :text=>"Bad Request" ,:layout=>false
  end

  def save_user_territory
    max_no_of_territories = current_user.number_of_territory.blank? ? 3 : current_user.number_of_territory.to_i
    if request.post?
      @user_territories = current_user.user_territories
      @states = State.find(:all,:order=>:state_code)
      @state_id = params[:state_code][:state_code] unless params[:state_code].blank?
      @territories = Territory.find(:all, :conditions=>["state_id = ? ", @state_id])
      @user_territory = UserTerritory.new(params[:user_territory])
      @user_territory.user_id = current_user.id
      if @user_territories.size == 0 
        @user_territory.sequeeze_page_number = 1
      elsif @user_territories.size < max_no_of_territories
        @user_territory.sequeeze_page_number = find_sequeeze_page_number(@user_territories)
      end
      redirect_to :action => :buyer_webpage and return if @user_territories.size > (max_no_of_territories - 1)
      if @user_territory.save
        flash[:notice] = "User Territory saved successfully"
        redirect_to :action => :territory_selection
      else
        @user_territories = current_user.user_territories
        if @user_territories.size > 2
          redirect_to :action=>:buyer_webpage
        else
          render :action=>:territory_selection
        end
      end
    else
      render :text=>"Bad Request", :layout=>false
    end
  end

  def get_territories
    if request.xhr?
      state_id = params[:state_id]
      @territories = Territory.find(:all, :conditions=>["state_id = ? ", state_id],:order=>:territory_name)
      render :layout=>false
    else
      render :text=>"Bad Request" ,:layout=>false
    end
  end


  def get_investor_territories
    if request.xhr?
      state_id = params[:state_id]
      @territories = Territory.find(:all, :conditions=>["state_id = ? ", state_id],:order=>:territory_name)
      render :layout=>false
    else
      render :text=>"Bad Request" ,:layout=>false
    end
  end

  def delete_user_territory
    user_territory = UserTerritory.find(params[:id])
    if user_territory.destroy
      flash[:notice] = "Territory has been deleted successfully" 
    else
      flash[:error] = "Error in deleting the territory" 
    end
    redirect_to :action => 'territory_selection'
  end


  #Investor Directory Page
  def investor_directory_page

    #Finding the first territory of user
    
    begin
      @territories = Array.new
      @states = State.find(:all,:conditions => ["name is not null"],:order=>:name)
      if request.get?
        if !current_user.user_territories.blank? && params[:territory_selected_id].blank? && params[:state_selected].blank?
          territory_id = current_user.user_territories.find(:all,:order=>"sequeeze_page_number")[0].territory_id 
          @investors = current_user.find_all_investors(territory_id,params[:page])
          #@investors = current_user.find_all_investors(164,params[:page])
          territory_used = Territory.find_by_id(territory_id)
          @state_selected = territory_used.state_id
          @country_selected = (!territory_used.country.blank? and territory_used.country == "ca") ? "CA" : "US"
          @territory_selected_id = territory_id
          @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
          @territories = (!@country_selected.blank? and @country_selected == "CA") ? Territory.find(:all, :conditions=>["country = ? ", @country_selected],:order=>:territory_name) : Territory.find(:all, :conditions=>["state_id = ? ", @state_selected],:order=>:territory_name)

          if @investors.blank?
            flash.now[:notice] = "There is no investor in your first territory."
          end
        elsif !params[:search_investor].blank?
          @territory_selected_id = params[:territory_selected_id]
          @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
          @state_selected = params[:state_selected]
          @territories = Territory.find(:all, :conditions=>["state_id = ? ", params[:state_selected]],:order=>:territory_name)
          @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
          function_for_investor_search
        elsif !params[:territory_selected_id].blank?  && !params[:state_selected].blank?
          @investors = current_user.find_all_investors(params[:territory_selected_id],params[:page])
          @territory_selected_id =params[:territory_selected_id]
          @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
          @state_selected = params[:state_selected]
          @territories = Territory.find(:all, :conditions=>["state_id = ? ", params[:state_selected]],:order=>:territory_name)
        else
          #If investor do not have any territroy
          flash.now[:notice] = "You do not have any territory." 
        end
      elsif request.post?
        @state_selected = params[:state_code][:state_code] unless params[:state_code].blank?
        @state_selected = params[:state_code_state_code] unless params[:state_code_state_code].blank?
        if params[:search_investor].blank?
          if !params[:user_territory].blank? && !params[:user_territory][:territory_id].blank?
            if !params[:country].blank? and params[:country][:country] == "CA"
              @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
              @territory_selected_id = params[:user_territory][:territory_id]
              @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
            else
              @territories = Territory.find(:all, :conditions=>["state_id = ? ", params[:state_code][:state_code]],:order=>:territory_name)
              @territory_selected_id = params[:user_territory][:territory_id]
              @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
            end
            @investors = current_user.find_all_investors(params[:user_territory][:territory_id],params[:page])
            if @investors.blank?
              flash.now[:notice] = "There is no investor in this territory."
            end
          else
            flash.now[:error] = "Please select a territory first."
          end
        else
          @territories = Territory.find(:all, :conditions=>["state_id = ? ", params[:state_code][:state_code]],:order=>:territory_name) unless params[:state_code].blank?
          @territories = Territory.find(:all, :conditions=>["state_id = ? ", params[:state_code_state_code]],:order=>:territory_name) unless params[:state_code_state_code].blank?
          @territory_selected_id = params[:user_territory][:territory_id] unless params[:user_territory].blank?
          @territory_selected_id = params[:user_territory_territory_id] unless params[:user_territory_territory_id].blank?
          @current_territory = Territory.find(:first, :conditions=>["id=?",@territory_selected_id])
          function_for_investor_search
        end
      end
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    @feeds = Feed.find(:all, :order => "id desc", :limit => 10)
    render :partial=>"investor_directory_page",:layout=>false if request.xhr? 
    @page_number = params[:page] if !params[:page].blank?
  end

  def get_feeds
    @feeds = Feed.find(:all, :order => "id desc", :limit => 10)
    render :partial=>"account/feed", :collection=>@feeds,:layout=>false
  end 
  
  def send_message_to_investor
    begin
      if request.get?
        @reciever_id  = params[:reciever_id]
        reciever = User.find_by_id(params[:reciever_id])
        @to_email = reciever.user_company_info.blank? ? reciever.email : reciever.user_company_info.business_email
        @investor_name = reciever.full_name
        
      elsif request.post?
        investor_message = current_user.investor_messages.create(:body=>params[:investor_message][:message],:subject=>params[:investor_message][:subject].to_s.strip)
        investor_message_recipient = investor_message.investor_message_recipients.create(:reciever_id=>params[:reciever_id])

        reciver = User.find_by_id(params[:reciever_id])
        Resque.enqueue(InvestorInboxMessageNotificationWorker, current_user.id, investor_message.id, reciver.email, reciver.id )
        #UserNotifier.deliver_investor_message_notification(current_user,investor_message,reciver.email,conversation_url)
        
        render :partial=>"message_sent", :layout=>false and return if !params[:from_investor_conversation]
        
        @investor_messages = InvestorMessage.paginate_by_sql(["select * from (select im.id as id,im.body as body,im.subject as subject,im.sender_id as sender_id,imr.reciever_id as reciever_id ,im.created_at as created_at from investor_messages as im,investor_message_recipients as imr where imr.investor_message_id = im.id and subject =?) as imj where (sender_id =? and reciever_id=?) or (reciever_id =? and sender_id=?) order by created_at desc",params[:investor_message][:subject].to_s.strip, params[:reciever_id] , current_user.id, params[:reciever_id] , current_user.id],{:page => params[:page]})
        @user_id = params[:reciever_id]
        
        
        render :action=>:investor_conversation,:layout=>false and return
      end
    rescue Exception=>exp
       ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    render :action=>:send_message_to_investor, :layout=>false
  end
  
  def investor_inbox
    begin
      if !current_user.blank?
        if params[:subject].blank?
           investor_messages = InvestorMessageRecipient.find_by_sql("select users.id as user_id,users.first_name as first_name, users.last_name as last_name,count(*) as no_of_message ,investor_message_recipients.is_read,investor_message_recipients.reciever_id, im.id,im.body, im.subject, im.created_at from (select * from investor_messages where sender_id = '#{current_user.id}' or id in (select investor_message_id from investor_message_recipients where reciever_id ='#{current_user.id}') order by id desc) as im,users,investor_message_recipients where users.id = im.sender_id and im.id = investor_message_recipients.investor_message_id group by subject order by im.created_at desc")
          undeleted_messages = is_investor_message_deleted(investor_messages)  
          if params[:filter_by].blank? || params[:filter_by] == "Current"
            filtered_message = undeleted_messages
          elsif params[:filter_by] == "Archived"
            filtered_message = investor_messages - undeleted_messages
          end
          @investor_filter_type = params[:filter_by]
           @investor_message_recieved = filtered_message.paginate :page => params[:page], :per_page => 10
        else
          @subject = params[:subject]
          @user_id = params[:user_id]
          @investor_message_id = params[:investor_message_id]
          @is_read = params[:is_read]
        end
      end
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    render :partial=>"investor_inbox",:layout=>false if request.xhr?
  end

# This is fo rprofile to profile message
  def profile_inbox
    @profile_message_recipients = sort_profile_message_recipients(ProfileMessageRecipient.find_by_sql("select * from profile_message_recipients where from_profile_id in (select id from profiles where user_id='#{current_user.id}') OR to_profile_id in (select id from profiles where user_id='#{current_user.id}')"))

       profile_messages = populate_tree(@profile_message_recipients)
        no_archieved = is_profile_message_deleted(profile_messages)
        if params[:filter_by].blank? ||  params[:filter_by] == 'Current' 
          paginate_tree = no_archieved
       elsif params[:filter_by] == 'Archived' 
          archieved = profile_messages - no_archieved
          paginate_tree = is_profile_message_not_deleted(archieved)
        end
        @filter_type = params[:filter_by]
       #paginate_tree = is_profile_message_deleted(profile_messages)
       @conversation_tree = paginate_tree.paginate :page => params[:page], :per_page => 10
       render :partial=>"profile_inbox",:layout=>false if request.xhr?
  end
  
  def getthread ( profile_message , profile_message_list ) 
    thread = [] 
    last_reply_message_id = profile_message.reply_to_profile_message_id
    thread.push(profile_message)
    profile_message_list.delete(profile_message)
    
    profile_message_list.each do |pm|
      if pm.id == last_reply_message_id
        thread.push(pm)
        profile_message_list.delete(pm)
        break if pm.reply_to_profile_message_id.nil?
        last_reply_message_id = pm.reply_to_profile_message_id
      end
    end
    thread.reverse
  end

  def already_processed ( pm )
    @message_list.each do |thread|
      thread.each do |processed_pm|
        return true if processed_pm.id == pm.id
      end
    end
    return false
  end

  def investor_full_page
    @uses_yui_lightbox = true
    if current_user.can_view?
      @user = User.find_by_id(params[:id])
    else
      @user = current_user
    end
    if @user.nil? 
      flash[:notice] = "This investor is not exist."
      redirect_to investor_network_path and return
    end
    @profiles = @user.active_profiles
    @property_profiles = []
    @property_profiles = @user.profiles.find_with_deleted(:all,:include=>[:profile_type, :profile_field_engine_index],:conditions=>[" profile_types.name = ? && profile_field_engine_indices.status = ? && profiles.deleted_at is null ","owner", "active" ]) if @profiles.size > 0
    @user_company_info = @user.user_company_info
    @user_territories = @user.user_territories
    @feeds = Feed.find_all_by_user_id(params[:id], :order => "id desc", :limit => 5)
    @buyer_user_image = BuyerUserImage.find_buyer_profile_image(params[:id])
    @territory_selected =  params[:user_territory_id]
    @state_selected = params[:state_code]
    @page_number = params[:page_number] if !params[:page_number].blank?
    @search_investor = params[:search_investor]
  end

  def investor_conversation
    begin
      if !params.blank? && !current_user.blank?
        
        if params[:from_investor_conversation].blank?
          @root_message_id = params[:investor_message_id]
          if !params[:is_read].blank? && params[:is_read] == "false" 
            investor_message_recipient = InvestorMessageRecipient.find(:first,:conditions=>["investor_message_id = ? and reciever_id =?",params[:investor_message_id],current_user.id])
            investor_message_recipient.update_attribute(:is_read,1) if !investor_message_recipient.blank?
            end
          @investor_messages = InvestorMessage.paginate_by_sql(["select * from (select im.id as id,im.body as body,im.subject as subject,im.sender_id as sender_id,im.spam_reason as spam_reason,im.marked_as_spam as marked_as_spam,imr.reciever_id as reciever_id ,im.created_at as created_at from investor_messages as im,investor_message_recipients as imr where imr.investor_message_id = im.id and subject =?) as imj where (sender_id =? and reciever_id=?) or (reciever_id =? and sender_id=?) order by created_at desc",params[:subject],params[:user_id] , params[:reciever_id], params[:user_id] , params[:reciever_id]],{:page => params[:page]})
          @user_id = params[:user_id]
        elsif !params[:from_investor_conversation].blank?
          investor_message = current_user.investor_messages.create(:body=>params[:investor_message][:message],:subject=>params[:investor_message][:subject].to_s.strip)
          investor_message_recipient = investor_message.investor_message_recipients.create(:reciever_id=>params[:reciever_id])
          
          @investor_messages = InvestorMessage.paginate_by_sql(["select * from (select im.id as id,im.body as body,im.subject as subject,im.sender_id as sender_id,im.spam_reason as spam_reason,im.marked_as_spam as marked_as_spam,imr.reciever_id as reciever_id ,im.created_at as created_at from investor_messages as im,investor_message_recipients as imr where imr.investor_message_id = im.id and subject =?) as imj where (sender_id =? and reciever_id=?) or (reciever_id =? and sender_id=?) order by created_at desc",params[:investor_message][:subject].to_s.strip, params[:reciever_id] , current_user.id, params[:reciever_id] , current_user.id],{:page => params[:page]})
          @user_id = params[:reciever_id]
          
          InvestorMessageDeleteHistory.destroy_all(["message=? and deleted_by=? and (sender =? or sender = ?)", params[:root_message_id],params[:reciever_id],current_user.id,params[:reciever_id]]) 
        
          @root_message_id = params[:root_message_id]
          reciver = User.find_by_id(params[:reciever_id])
          Resque.enqueue(InvestorInboxMessageNotificationWorker, current_user.id, investor_message.id, reciver.email, reciver.id)
          #UserNotifier.deliver_investor_message_notification(current_user,investor_message,reciver.email,conversation_url)
        end        
      end
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    render :layout=>false
  end

  def delete_investor_inbox_message
    if !params[:investor_message].blank?
      params[:investor_message].each do |param|
        begin
          param_arr = param.split("#user_id#") #first will be message id and second will be user_id
          InvestorMessageDeleteHistory.create(:message=>param_arr[0].to_s.strip,:deleted_by=>current_user.id,:sender=>param_arr[1])
          rescue Exception => exp
          ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        end
      end
      flash[:notice] = "Messages archived successfully."
    else
      flash[:error] = "Please select atleast one message to archive."
    end
    redirect_to :action=>:investor_inbox
  end
  
  #Deleting profile inobx messages
  def delete_profile_inbox_message
    if !params[:profile_message].blank?
      params[:profile_message].each do |param|
          begin
            param_arr = param.split("#profile_id#") #first will be subject and second will be user_id
            
            ProfileMessageDeleteHistory.create(:subject=>param_arr[0].to_s.strip,:deleted_by=>current_user.id,:sender=>param_arr[1]) if !param_arr[1].eql?('nil')
          rescue Exception => exp
            ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
          end
      end
      flash[:notice] = "Messages archived successfully."
    else
      flash[:error] = "Please select atleast one message to archive."
    end
    redirect_to :action=>:profile_inbox
  end


  def facebook
    if !current_user.fb_access_token.blank?
      render :file => "account/facebook.html.erb", :layout => true
    else 
      uri = REIMATCHER_URL + "account/fb_callback"
      redirect_to "https://graph.facebook.com/oauth/authorize?scope=offline_access,publish_stream&client_id="+ FACEBOOK[:key] + "&redirect_uri=" + uri
    end
  rescue Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    flash[:error] = "Something went wrong. Please try again or contact support"
    redirect_uri = REIMATCHER_URL + 'account/property-syndication'
    redirect_to redirect_uri.gsub(/\b(\/\/)/, "/")
  end
  
  def fb_reconnect    
    if params[:commit] == "Reconnect" 
      uri = REIMATCHER_URL + "account/fb_callback"
      redirect_to "https://graph.facebook.com/oauth/authorize?scope=offline_access,publish_stream&client_id="+ FACEBOOK[:key] +"&redirect_uri=" + uri
    elsif params[:commit] == "Disconnect" 
      user = current_user
      user.fb_access_token = ''
      user.save
      flash[:notice] = "Facebook was successfully disconnected from your account"
      redirect_to '/account/property-syndication'
    end
  rescue Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    flash[:error] = "Something went wrong. Please try again or contact support"
    redirect_uri = REIMATCHER_URL + 'account/property-syndication'
    redirect_to redirect_uri.gsub(/\b(\/\/)/, "/")
  end
  
  def fb_callback
    callback_uri = REIMATCHER_URL + "account/fb_callback"
    if !params[:error].nil? && params[:error] == "access_denied"
      flash[:error] = "You denied permission to reimatcher app. We won't be able to syndicate your properties on facebook"
    else
      if !params[:code].nil?
        client = FacebookOAuth::Client.new(
                                           :application_id => FACEBOOK[:key],
                                           :application_secret => FACEBOOK[:secret],
                                           :callback => callback_uri,
                                           :ssl => {:ca_path => "/etc/ssl/certs"}
                                           )
        access_token = client.authorize(:code => params[:code])
        user = current_user
        user.fb_access_token = access_token.token
        user.save
        flash[:notice] = "Facebook was successfully connected to your account"
      end
    end
    redirect_to '/account/property-syndication'
  rescue Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    flash[:error] = "Something went wrong. Please try again or contact support"
    redirect_uri = REIMATCHER_URL + 'account/property-syndication'
    redirect_to redirect_uri.gsub(/\b(\/\/)/, "/")
end

  def update_investor_territory
      if !params[:country_id].blank? and params[:country_id] == "CA" 
        @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
        render :partial => 'update_canada_territory_for_investor'        
      else
        @territories = Array.new
        @states = State.find(:all,:conditions => ["name is not null and country = ?",params[:country_id]], :order=>:name)
        render :partial => 'update_us_territory_for_investor'        
      end 
  end


  def social_media
    media_accounts = SocialMediaAccount.find_all_by_user_id(current_user.id)
    @buyer_url = Hash.new
    @seller_url = Hash.new
    media_accounts.each do |media_acc|
      @buyer_url[media_acc.url_type_id] = media_acc.url if media_acc.site_type_id == SocialMediaAccount::SITE_TYPE[:BUYER_WEBSITE]
      @seller_url[media_acc.url_type_id] = media_acc.url if media_acc.site_type_id == SocialMediaAccount::SITE_TYPE[:SELLER_WEBSITE]
    end
  end
  
  def save_social_media_accounts
    params[:buyer_website].each do |k,v|
      v = v.gsub(/\s/,"") unless v.nil?
      SocialMediaAccount.add(v, current_user.id, k.to_i, SocialMediaAccount::SITE_TYPE[:BUYER_WEBSITE])
    end
    params[:seller_website].each do |k,v|
      v = v.gsub(/\s/,"") unless v.nil?
      SocialMediaAccount.add(v, current_user.id, k.to_i, SocialMediaAccount::SITE_TYPE[:SELLER_WEBSITE])
    end
    flash[:notice] = "Your Social Media accounts have been successfully updated"
    redirect_to :action=>:social_media
  end

  def show_deals
    @deleted_profiles = DeletedProfile.get_deleted_profiles(current_user.id).paginate :page => params[:page], :per_page => 10
  end

  def manage_deal
    @deleted_profile = DeletedProfile.find(:first, :conditions => ["id = ? and user_id = ?",params[:id], current_user.id])
    unless @deleted_profile.blank? 
      @comment_flag  = (@deleted_profile.profile_delete_reason_id == "other_owner" or @deleted_profile.profile_delete_reason_id == "other_buyer") ? true : false
      @profile_delete_reasons = ProfileDeleteReason.find_for_profile(@deleted_profile)
    else
      render :file => REI_404_PAGE
    end
  end

  def update_deal
    @deleted_profile = DeletedProfile.find(:first, :conditions => ["id = ? and user_id = ?",params[:id], current_user.id])
    if !@deleted_profile.blank? and request.post?
      if @deleted_profile.update_attributes(:profile_delete_reason_id => params[:profile_form][:profile_delete_reason_id], :delete_reason => params[:profile_form][:delete_reason], :updated_at => @deleted_profile.updated_at)
        flash[:notice] = "Your deal has been successfully updated"
        redirect_to :controller => "account", :action  => :show_deals
      else
        @profile_delete_reasons = ProfileDeleteReason.find_for_profile(@deleted_profile)
        render :action => :manage_deal
      end
    else
      render :file => REI_404_PAGE
    end
  end
  
  def receive_email
    begin
      id = params["to"][params["to"].rindex('<') + 1..params["to"].rindex('@') - 1].split(".") if !params["to"].rindex('<').nil?
      id = params["to"][0..params["to"].rindex('@') - 1].split(".") if params["to"].rindex('<').nil?
      user = User.find(id[0]) 
      investor_message = InvestorMessage.find(id[1])
      investor_message_recipent = investor_message.investor_message_recipients.first
      if user.id == investor_message_recipent.reciever_id
        InvestorMessage.transaction do 
          email_body = params["text"] if !params["text"].nil?
          email_body = params["html"] if params["text"].nil?
          inv_mssg = InvestorMessage.create(:body=>process_email_body(email_body),:subject=>investor_message.subject, :sender_id => investor_message_recipent.reciever_id)
          inv_mssg_rcpt = inv_mssg.investor_message_recipients.create(:reciever_id=>investor_message.sender_id)
          reciver = User.find_by_id(investor_message.sender_id)
          Resque.enqueue(InvestorInboxMessageNotificationWorker, user.id, inv_mssg.id, reciver.email, reciver.id )      
          render :text => "OK", :status => 200        
        end
      end
    rescue Exception => exp
      logger.info("Incoming Email Exception: #{exp}")
      ExceptionNotifier.deliver_exception_notification( exp, self, request, params)
      render :text => "Error in Email Processing", :status => 500
    end
  end
  private
  
  def process_email_body(email)
    email = email.gsub(/<(.|\n)*?>/, "")                                            #Strip HTML
    reply_array = email.split("## To Reply, simply add your response above this message and click Send")
    reply_array = reply_array[0].split(/On[\s\w+\,\s\d:]*/)
    reply = reply_array[0].gsub(/On[\s\w+\,\s\d:]*<\s[\s\w+\-\.@]*>[\w+\s:\*>]*/, '').gsub(/\240/, "") #gmail
    reply = reply.split("________________________________")                         #Yahoo Mail
    reply = reply[0].split(/From:\sREIMatcher\s&lt;[\w+\-\.@]*/)                    #Rediffmail
    reply = reply[0].split(/Date: [\w+,\d\s:\-]*From:\s[\w+\-\.@]*/)                #Hotmail
    reply = reply[0].split(/--------[\s\w+]+--------/)                              #mysilverlining.info Domain
    return reply[0]
  end
  
  def territory_required
    @user_territories  = current_user.user_territories.find(:all,:order=>"sequeeze_page_number")
    if @user_territories.size < 1
      flash[:notice] = "Please select territories."
      redirect_to :action => 'territory_selection', :controller=>:account and return
    end
  end
  
  def find_sequeeze_page_number(user_territories)
    page_number, page = [],0
    user_territories.each { |user_territory|  page_number << user_territory.sequeeze_page_number  }
    for i in 1..(page_number.size + 1) do 
      (page = i and break ) if page_number.index(i).blank? 
    end
    return page
  end
  
  def default_investor_buyer_web_page_search()
    territory_profiles = Profile.find(:all, :select => "profiles.*, profile_field_engine_indices.zip_code", :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and (zip_code in (#{@zip_code_array.join(",")})) and users.activation_code is null  " , :order=>"created_at DESC", :group=>"profile_field_engine_indices.profile_id, profile_field_engine_indices.property_type", :limit => @page_number*5)
    @total_records = @total_records || Profile.count(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and (zip_code in (#{@zip_code_array.join(",")})) and users.activation_code is null")
    @total_pages = (@total_records / PROPERTIES_PER_PAGE.to_i).to_i + (@total_records % PROPERTIES_PER_PAGE.to_i > 0 ? 1 : 0)
    per_page = @page_number - 1
    @profiles = territory_profiles[per_page.to_i * PROPERTIES_PER_PAGE.to_i,PROPERTIES_PER_PAGE.to_i]
  end
  
  def get_territory_profile(user_profiles , territory)
    territory_profiles = Array.new
    user_profiles.each do |profile|
      if territory.zips.map(&:zip).include?(profile.display_zip_code)
        territory_profiles.push(profile)
      end
    end
    return territory_profiles
  end
  
  def get_gmap_setting(param_zip_code)
    @zip_code = param_zip_code || ''
    # use ip address to guess location
    geoip = GeoIP.new(RAILS_ROOT + '/public/geoip/GeoLiteCity.dat').city( self.request.remote_ip )
    geoip_zip_code = geoip[ 8 ] unless geoip.nil?
    if !geoip_zip_code.nil? && !geoip_zip_code.empty?
      @directions_available = Zip.find(:all, :conditions => ["city LIKE ? and state LIKE ? and direction is not null", geoip[ 7 ], geoip[ 6 ]])
    else
      @directions_available = Zip.find(:all, :conditions => ["city LIKE 'Austin' and state LIKE 'TX' and direction is not null"])
    end
    geoip_zip_code = '78701' if geoip_zip_code.nil? || geoip_zip_code.empty?
    @map = ZipCodeMap.prepare_map(geoip_zip_code)
  end

  def get_paragraph_marketing(summary_type)
    @user_company_image = UserCompanyImage.find_by_user_id(current_user.id)
    @buyer_notification = BuyerNotification.find(:first,:conditions => ["user_id LIKE ? and summary_type LIKE ?",current_user.id,summary_type])
    if @buyer_notification.nil?
      @buyer_notification = BuyerNotification.new
    end

    ui_info = @buyer_notification.ui_display_details summary_type
    @name = ui_info[0]
    @note = ui_info[1]
    @links = ui_info[2] if ui_info[2]
    @static_mails = ui_info[3] if ui_info[3] 
  end
  
  def populate_tree( profile_message_list )
    tree = [] 
    already_processed_messages = []
    profile_message_list.each do |pmsg|
      if !already_processed_messages.include?(pmsg)
        related_message_recipients , related_messages  = find_all_related_messages(pmsg , profile_message_list)
        already_processed_messages.concat( related_message_recipients) 
        parent_node = build_thread(related_messages) 
        tree << parent_node
      end
    end
    return tree 
  end

  def find_all_related_messages(orig_msg , message_list)
    profile_messages = [] 
    profile_message_recipients = []
    conversation_profile_id = "" 
    profile_id = ""
    current_user.profiles.each do |profile_id|
      if profile_id.id == orig_msg.to_profile_id 
        conversation_profile_id , profile_id = orig_msg.from_profile_id , profile_id.id 
        break 
      end
      if profile_id.id == orig_msg.from_profile_id
        conversation_profile_id , profile_id = orig_msg.to_profile_id ,profile_id.id 
        break 
      end 
    end

    message_list.each do |msg|
      if ((msg.to_profile_id == conversation_profile_id || msg.from_profile_id == conversation_profile_id ) && (msg.to_profile_id == profile_id || msg.from_profile_id == profile_id )&& (clean_subject(msg.profile_message.subject) == clean_subject(orig_msg.profile_message.subject)))
        # this is a message in the same thread 
        profile_messages << msg.profile_message
        profile_message_recipients << msg
      end
    end
    return profile_message_recipients , profile_messages
  end

  def build_thread (related_messages) 
    sorted_list  = sort_profile_message(related_messages)
    i = 0 
    last_parent = nil
    main_parent = nil   
    sorted_list.each do |profile_message|
      if i == 0 
        main_parent= get_root_struct(profile_message)
        last_parent = main_parent
        i = i + 1
      else
        child = ProfileMessageTempStruct.new(profile_message)
        child.parent = last_parent
        last_parent.children << child
        last_parent = child
      end
    end
    main_parent
  end

  def clean_subject(subject_string)
    return subject_string.gsub("Re: ","")
  end


  def sort_profile_message(thread_msgs)
    sorted_thread_msgs = thread_msgs.sort{|x, y| x.created_at <=> y.created_at }
  end

  def sort_profile_message_recipients(profile_message_recipients)
    sorted_thread_msgs = profile_message_recipients.sort{|x, y| y.profile_message.created_at <=> x.profile_message.created_at }
  end
  
  def get_root_struct(pm)
    return_value = ProfileMessageTempStruct.new(pm)
    return_value.parent = nil 
    return return_value
  end
  
  def is_investor_message_deleted(investor_message_recieved)
    final_investor_message_recieved = []
    if !investor_message_recieved.blank?
      investor_message_recieved.each do |imr|
        investor_message_history = InvestorMessageDeleteHistory.find(:all,:conditions=>["message =? and deleted_by = ? and sender=?",imr.id,current_user.id,imr.user_id])
        if investor_message_history.size == 0 
          final_investor_message_recieved << imr
        end
      end
    end
    return final_investor_message_recieved
  end
  
  def is_profile_message_deleted(profile_messages)
    final_profile_message_recieved = []
    
    profile_messages.each do |profile_message|
      next if profile_message.blank?
      pmr = profile_message.message.profile_message_recipients
      if pmr.size > 0 
        profile_message_history = ProfileMessageDeleteHistory.find(:all,:conditions=>["(subject =?) and deleted_by = ? and sender=?",profile_message.message.id,current_user.id,pmr[0].from_profile_id])
        if profile_message_history.size == 0 
          to_profile ,from_profile = get_profile_ids(profile_message.message.id)
          if !to_profile.nil? && !from_profile.nil?
            final_profile_message_recieved << profile_message  
          end
        end
      end
    end
    
    return final_profile_message_recieved
  end
  
  def is_profile_message_not_deleted(archieved_profile_messages)
    final_profile_message_recieved = []
    
    archieved_profile_messages.each do |profile_message|
      to_profile ,from_profile = get_profile_ids(profile_message.message.id)
      if !to_profile.nil? && !from_profile.nil?
        final_profile_message_recieved << profile_message  
      end
    end
    
    return final_profile_message_recieved
  end
  
  def get_profile_ids(profile_message_id)
    profile_info = ProfileMessageRecipient.find(:all,:conditions=>["profile_message_id=?",profile_message_id])
    profile_info.each do |pro_info|
      return_to_profile = pro_info.to_profile
      return_from_profile = pro_info.from_profile
      if return_to_profile.user_id == current_user.id || return_from_profile.user_id == current_user.id
        return return_to_profile , return_from_profile
        break
      end
    end
    return nil, nil
  end
  
  def function_for_investor_search
    @search_investor = params[:search_investor].to_s.gsub("OR","or").gsub("AND","and")
    search = ActsAsXapian::Search.new([User], @search_investor, {:limit=>1000, :offset=>0})
    @all_investors = []
    search.results.each { |result|
    @all_investors << result[:model]
    }
    @current_territory_investors = []
    search.results.each { |result|
      invstr = result[:model].user_territories.find(:all,:conditions=>["territory_id=?",@territory_selected_id]) unless result[:model].user_territories.blank?
      @current_territory_investors << result[:model] unless invstr.blank?
    }

    @other_investors = @all_investors - @current_territory_investors
    @other_investors = @other_investors.sort {|x,y| y.activity_score <=> x.activity_score}
    @current_territory_investors = @current_territory_investors.sort {|x,y| y.activity_score <=> x.activity_score}
    inv_arr = []
    inv_arr = @current_territory_investors + @other_investors
    @investors = inv_arr.paginate :page => params[:page], :per_page => PROFILES_PER_PAGE
    @total_investors = search.matches_estimated
  end
end


class ProfileMessageTempStruct
  attr_accessor :parent , :message , :children 
  def initialize(pm_message)
    self.message = pm_message
    self.children = Array.new()
  end

  def size 
     return 1 if self.children.size == 0 
     size = 1
    children.each do |child|
      size = size + child.size
    end
    return size
  end

  def root_message_id
    temp_struct = self
    while !temp_struct.parent.nil?
      temp_struct = temp_struct.parent
    end
    temp_struct.message.id
  end
end
