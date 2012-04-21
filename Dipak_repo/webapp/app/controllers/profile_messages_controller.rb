class ProfileMessagesController < ApplicationController
  before_filter :login_required
  before_filter :load_profile, :except=>[:archive, :new_community, :create_community]
  before_filter :check_profile_ownership, :except=>[:archive, :new_community, :create_community]

  #before_filter :check_investor_role, :only=>["new"]
#   before_filter :only=>["new","new_community"] do  |controller|  
#     controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc1_type],BASIC_USER_CLASS[:uc2_type]])
#   end

  layout "application"

  RESULTS_PER_PAGE = 10

  # GET /profile_messages
  # GET /profile_messages.xml
  def index    
    @page_number = (params[:page_number] || "1").to_i
    @offset = @page_number == 1 ? nil : (@page_number-1) * RESULTS_PER_PAGE
    default_sort_type = "created_at,desc"
    @sort = (params[:sort] || default_sort_type)
    @sort_type = @sort.split(',')[0]
    @sort_order = @sort.split(',')[1]
    @message_filter = (params[:message_filter] || "All")
    @listing_type = (params[:listing_type] || "all")
    @listing_type = "all" if @listing_type.empty?
    @profile_message_recipients, @total_pages = ProfileMessageRecipient.find_distinct_for(@profile, @offset, RESULTS_PER_PAGE, "pmr.viewed_at ASC, pm.created_at DESC", @message_filter, @listing_type)
   
    respond_to do |format|
      format.html  do
        render :partial=>"list_messages" and return if request.xhr?
      end
      format.xml   { render :xml => @profile_message_recipients.to_xml }
      format.json  { render :json => @profile_message_recipients.to_json() }
    end
  end

  # GET /profile_messages/1
  # GET /profile_messages/1.xml
  def show
    @profile_message = ProfileMessage.find(params[:id])
    @profile_message_recipients = ProfileMessageRecipient.find_for_message(@profile_message, @profile)
    @message_from_profile = @profile_message_recipients[0].from_profile

    if !@profile_message_recipients.empty?
      begin
        @profile_message_recipients.each do |profile_message_recipient|
          profile_message_recipient.mark_as_read!
        end
      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        msg = "Error marking profile_message_recipient #{@profile_message_recipient.id} as read. This message has been logged but will not impact the user. Details: "+e.to_s
        logger.error(msg)
        puts(msg)
      end
    end

    respond_to do |format|
      format.html { render :partial=>"/shared/profile_message" and return if request.xhr? }
      format.xml  { render :xml => @profile_message.to_xml }
    end
  end

  # GET /profile_messages/news
  def new
    @retail_buyer_profile = Profile.find(params[:retail_buyer_profile]) if(params[:retail_buyer_profile])
    @listing_type = (params[:listing_type] || "all")
    @listing_type = "all" if @listing_type.empty?
    @result_filter = (params[:result_filter] || "all")
    @result_filter = "all" if @result_filter.empty?
    
    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash(params["profile_message_form"]) if params["profile_message_form"]
    @profile_message_form.filters = ["all"]
    if @profile_message_form.message_for_indiv?
      @indiv_profile = Profile.find(@profile_message_form.indiv_profile_id)
      @match_count = 1
    else
      @match_count = @profile.total_near_count_matching(@listing_type, @result_filter)
    end
    @has_selected_send_to = (!@profile_message_form.send_to.nil? and @profile_message_form.send_to.length > 0)

    @return_path = get_new_message_return_path(false)

    if !@profile_message_form.reply_to_profile_message_id.nil?
      # this is a reply - preset the subject line
      @reply_to_message = ProfileMessage.find_by_id("#{@profile_message_form.reply_to_profile_message_id}")
      @profile_message_form.subject = "Re: #{@reply_to_message.subject}" if @reply_to_message
    end
    
    if @profile.buyer? or @profile.buyer_agent?
      type = "#{"Sellers"} and #{"Seller Agents"}"
      type = "FSBO Listings" if @listing_type == 'fsbo'
      type = "Agent Listings" if @listing_type == 'listed'
    else
      type = "#{"Buyers"} and #{"Buyer Agents"}"
      type = "Buyers" if @listing_type == 'buyer'
      type = "Buyer Agents" if @listing_type == 'buyer_agent'
    end
    if params['profile_message_form']['send_to'].to_s == 'favorites'
      @send_to_description = "#{type} you have marked as favorite"
    elsif params['profile_message_form']['send_to'].to_s == 'new'
      @send_to_description = "#{type} that are new since you last logged in"
    elsif params['profile_message_form']['send_to'].to_s == 'viewed_me'
      @send_to_description = "#{type} that have viewed your profile"
    else
      @send_to_description = "All matched #{type}"
    end

    render :layout=>false if request.xhr?
  end
  
  # GET /community_message
  # This is mostly a copy of new, but used to allow users to send messages
  # without being associated with a profile.
  def new_community    
    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash(params["profile_message_form"]) if params["profile_message_form"]
    @profile_message_form.filters = ["all"]
    if @profile_message_form.message_for_indiv?
      @indiv_profile = Profile.find(@profile_message_form.indiv_profile_id)
    end
    @has_selected_send_to = (!@profile_message_form.send_to.nil? and @profile_message_form.send_to.length > 0)
    
    @return_path = get_new_message_return_path(true)

    if !@profile_message_form.reply_to_profile_message_id.nil?
      # this is a reply - preset the subject line
      @reply_to_message = ProfileMessage.find_by_id("#{@profile_message_form.reply_to_profile_message_id}")
      @profile_message_form.subject = "Re: #{@reply_to_message.subject}" if @reply_to_message
    end
    
    @my_profiles = get_profiles_for_community_message(@indiv_profile)
    @req_uri_for_mp = request.query_string

    render :action=>"new", :layout=>!request.xhr?
  end
  

  # GET /profile_messages/1;edit
  def edit
    @profile_message = ProfileMessage.find(params[:id])
  end

  # Add a message using a profile chosen from a dropdown
  def create_community
    id = params[:profile_message_form][:from_profile_id] if !params[:profile_message_form].nil?
    @profile = Profile.find(id) if !id.blank?
    @community = true
    @return_path_for_mp = params[:req_uri_for_mp]
    create
  end
  
  # POST /profile_messages
  # POST /profile_messages.xml
  def create
    # render :text=>"<PRE>#{YAML::dump(@params)}</PRE>"
    @retail_buyer_profile = Profile.find(params[:retail_buyer_profile]) if(!params[:retail_buyer_profile].blank?)
    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash(params[:profile_message_form])
    @listing_type = (params[:listing_type] || "all")
    @listing_type = "all" if @listing_type.empty?
    @result_filter = (params[:result_filter] || "all")
    @result_filter = "all" if @result_filter.empty?
    
    @has_selected_send_to = (!@profile_message_form.send_to.nil? and @profile_message_form.send_to.length > 0)
    if @profile_message_form.message_for_indiv?
      @indiv_profile = Profile.find(@profile_message_form.indiv_profile_id)
    end
    if @profile_message_form.valid?
      @profile_message = @profile_message_form.to_profile_message(@profile, @listing_type, @result_filter)
      begin
        @profile_message.each do |message|
            message.save!
    
            # iterate through each recipient and send the personal message notification email to each one
    
            # track which users have been notified already to prevent duplicate notifications for users
            # that have more than one profile
            users_already_sent_to = Array.new
            message.profile_message_recipients.each do |pmr|
              # deliver the direct message to the subscriber, but only if they have their flag set to immediate (default)
              if pmr.to_profile.user.deliver_direct_message_immediately? and !users_already_sent_to.include?(pmr.to_profile.user_id)
                #sending email through Resque
                Resque.enqueue(DirectMessageNotificationWorker, pmr.id )
                # Don't track yet, but we may want this in the future users_already_sent_to << pmr.to_profile.user_id
              end
              # When a new messages comes in, we want to unarchive all the conversations
              Profile.connection.update("UPDATE profile_message_recipients SET archived = 0 WHERE from_profile_id = '#{pmr.from_profile_id}' and to_profile_id = '#{pmr.to_profile_id}'")
            end
        end
        
        @return_path = get_create_message_return_path()
        @return_path_for_mp = params[:req_uri_for_mp]
        
        respond_to do |format|
          format.html do
            if @return_path_for_mp.to_s.include?("filter_results")
              flash[:notice] = "Your message was successfully sent."
              if @return_path_for_mp.to_s.include?("target_profile_type=buyer")
                redirect_to "#{REIMATCHER_URL}home/preview_buyer/#{@indiv_profile.id}?#{@return_path_for_mp}" and return
              elsif @return_path_for_mp.to_s.include?("target_profile_type=owner")
                redirect_to "#{REIMATCHER_URL}home/preview_owner/#{@indiv_profile.id}?#{@return_path_for_mp}" and return
              end
            end
            if request.xhr?
              flash.now[:notice] = "Your message was successfully sent."
              render :partial=>"create_success" and return
            end

            flash[:notice] = "Your message was successfully sent."
            # catch all for clients that didn't process the client-side javascript properly (ticket #345)
            # or for clients that are viewing the full page rather than the xhr version
            if !@indiv_profile.nil?
              # profile full page view
              redirect_to @return_path and return
            else
              # dashboard
              redirect_to @return_path and return
            end
          end
          #format.xml  { head :created, :location => profile_profile_message_url(@profile_message) }
        end
        rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        handle_error("Error creating your message. The message has not been delivered to recipients.",e) and return
      end
    end
    
    if @community
      @profile = nil
      @my_profiles = get_profiles_for_community_message(@indiv_profile)
    end
    @return_path = get_new_message_return_path(@community)
    
    render :action=>"new", :layout=>!request.xhr?
  end

  # PUT /profile_messages/1
  # PUT /profile_messages/1.xml
  def update
    @profile_message = ProfileMessage.find(params[:id])

    respond_to do |format|
      if @profile_message.update_attributes(params[:profile_message])
        flash[:notice] = 'ProfileMessage was successfully updated.'
        format.html { redirect_to profile_profile_message_url(@profile_message) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile_message.errors.to_xml }
      end
    end
  end

  # DELETE /profile_messages/1
  # DELETE /profile_messages/1.xml
  def destroy
    @profile_message = ProfileMessage.find(params[:id])
    @profile_message.destroy

    respond_to do |format|
      format.html { redirect_to profile_profile_messages_url }
      format.xml  { head :ok }
    end
  end

  #
  # Marks a profile as spam by anyone in the system, even from a guest visitor from the preview page
  #
  def mark_as_spam
    @profile_message = ProfileMessage.find(params[:id])
    the_dom_id = params[:dom].gsub('-','_') if params[:dom]
    spam_claim = SpamClaim.new({ :claim_type=>'ProfileMessage', :claim_id=>@profile_message.id, :created_by_user_id=>current_user.id})
    begin
      spam_claim.save!
      spam_claim.connection.update("UPDATE profile_messages SET marked_as_spam = true WHERE id = '#{@profile_message.id}'")

      #sending email through Resque
      Resque.enqueue(ProfileMessageMarkedAsSpamNotificationWorker,spam_claim.id, @profile_message.id)
      render :update do |page|
        # add the new tag to the top of the table
        page.replace_html "marked_as_spam_#{the_dom_id}", "Marked as spam"
        # highlight the new text
        page.visual_effect :highlight, "marked_as_spam_#{the_dom_id}"
      end if request.xhr?

    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification( e, self, request, params)
      handle_error("Internal error - could not mark as spam",e) and return
    end
  end
  
  def archive
    begin
      pmr = ProfileMessageRecipient.find(params[:id])
      if pmr
        if pmr.to_profile.user != current_user
          raise "User/Conversation mismatch"
        end
        Profile.connection.update("UPDATE profile_message_recipients set archived = 1, viewed_at = sysdate() where to_profile_id = '#{pmr.to_profile_id}' and from_profile_id = '#{pmr.from_profile_id}'")
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification( e,self, request, params)
      logger.error("Error archiving conversation #{e.message}")
      handle_error("Error archiving conversation",e) and return
    end
    render :text=>"success" and return
  end
  
  # When they go to add a message they could have come from many different places
  # and we have to build the correct return path.
  def get_new_message_return_path(community)
    if community
      if params[:ref] == 'search'
        return_path = url_for(:controller=>'search', :action=>"preview_#{params[:target_profile_type]}", :id=>@indiv_profile.id)
      elsif !params[:investor_full_page].blank?
        return_path = url_for(:controller=>'home', :action=>"preview_#{params[:target_profile_type]}", :id=>@indiv_profile.id, :investor_full_page=>params[:investor_full_page], :state_code=> params[:state_code], :user_territory_id=> params[:user_territory_id], :search_investor=> params[:search_investor], :page_number => params[:page_number])
      else
        return_path = url_for(:controller=>'home', :action=>"preview_#{params[:target_profile_type]}", :id=>@indiv_profile.id)
      end
    else
      if @indiv_profile.nil? || params[:ref] == 'list'
        if !@retail_buyer_profile.nil?
          #buyer leads
          return_path = url_for(:controller=>'buyer_websites', :action=>"buyer_lead_match", :id=> @profile.id)
         else
          return_path = profile_path(@profile)
         end
      else
        if !@retail_buyer_profile.nil?
          #buyer leads
          return_path = profile_profile_view_path(@profile, @indiv_profile)
          #return_path = url_for(:controller=>'buyer_websites', :action=>"buyer_lead_match", :id=> @profile.id, :result_filter => @result_filter)
        else
          # profile full page view
          return_path = profile_profile_view_path(@profile, @indiv_profile)
        end
      end
    end
    return_path
  end
  
  # This is the return path for when they successfully send the message
  def get_create_message_return_path
    if !@indiv_profile.nil?
      if @community
        if params[:ref] == 'search'
          return_path = url_for(:controller=>'search', :action=>"preview_#{params[:target_profile_type]}", :id=>@indiv_profile.id)+"?"+encode_return_dashboard_params+'&ref=search'
        else
          return_path = url_for(:controller=>'home', :action=>"preview_#{params[:target_profile_type]}", :id=>@indiv_profile.id)+"?"+encode_return_dashboard_params
        end
      elsif !params[:investor_full_page].blank?
        return_path = url_for(:controller=>'home', :action=>"preview_owner", :id=>@indiv_profile.id, :investor_full_page=>params[:investor_full_page], :state_code=> params[:state_code], :user_territory_id=> params[:user_territory_id], :search_investor=> params[:search_investor], :page_number => params[:page_number])
      else
        # profile full page view
         if !@retail_buyer_profile.nil?
          #buyer leads
           return_path = profile_profile_view_path(@profile, @indiv_profile)+"?retail_buyer_profile="+@retail_buyer_profile.id
          #return_path = url_for(:controller=>'buyer_websites', :action=>"buyer_lead_match", :id=> @profile.id, :result_filter => @result_filter)
         else
          return_path = profile_profile_view_path(@profile, @indiv_profile)+"?"+encode_return_dashboard_params
         end
      end
    else
      if !@retail_buyer_profile.nil?
          #buyer leads
          return_path = url_for(:controller=>'buyer_websites', :action=>"buyer_lead_match", :id=> @profile.id, :result_filter => @result_filter )
      else
           #dashboard
          return_path = profile_path(@profile)+"?"+encode_return_dashboard_params
      end
      
    end
    return_path
  end
  
  # This is the dropdown list for when the user is browsing or searching the community and they
  # haven't chosen a profile yet.
  def get_profiles_for_community_message(to_profile)
    if to_profile 
      conditions = "profile_types.name in ('buyer', 'buyer_agent')" if (to_profile.owner? or to_profile.seller_agent?)
      conditions = "profile_types.name in ('owner', 'seller_agent')" if (to_profile.buyer? or to_profile.buyer_agent?)
    end
    @my_profiles = current_user.profiles.find(:all, :conditions=>conditions, :order=>"profile_types.name", :include=>"profile_type")
 
#    if @my_profiles.length == 1
    if !@my_profiles.blank?
      @profile = @my_profiles.first
      return nil
    end
    options = ActiveSupport::OrderedHash.new
    options["-- Select a Profile to Send From --"] = ""
    @my_profiles.each do | profile |
      options[profile.unambiguous_name] = profile.id
    end
    options
  end
end