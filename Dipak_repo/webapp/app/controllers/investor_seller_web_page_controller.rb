class InvestorSellerWebPageController < ApplicationController

  before_filter :check_seller_permalink
  layout "investor_seller_webpage"

  def seller_web_page
    @seller_lead_testimonials=SellerLeadTestimonail.find(:all, :order=>"RAND()", :limit => 1 )
  end

  def create_seller_lead_opt_in
    if request.post?
      @lead_opt_in=SellerLeadOptIn.new()
      @lead_opt_in.from_hash(params['lead_opt_in'])
      @lead_opt_in.seller_website_id = @seller_website.id
      if @lead_opt_in.valid?
        @lead_opt_in.save
        redirect_to :action => "new_seller", :permalink_text => params[:permalink_text], :first_name => @lead_opt_in.seller_first_name, :email => @lead_opt_in.seller_email
      else
        render :action => "seller_web_page", :permalink_text => params["permalink_text"], :layout=>true
      end
    else
      redirect_to :controller=>:home,:action=>:index
    end
  end

  def new_seller
    @seller_profile = SellerProfile.new()
    @seller_profile.first_name = params[:first_name] unless params[:first_name].blank?
    @seller_profile.email = params[:email] unless params[:email].blank?
    @fields = SellerPropertyProfile.new()
  end

  def create_new_seller_profile
    begin
      if request.post?
        @seller_profile = SellerProfile.new()
        @seller_profile.from_hash(params['seller_profile']) unless params['seller_profile'].blank?
        @fields = SellerPropertyProfile.new()
        params['fields']['notification_email'] = @seller_profile.email
        params['fields']['notification_phone'] = @seller_profile.phone
        params['fields']['property_type'] = "single_family"
        @fields.from_hash(params['fields']) unless params['fields'].blank?
        @seller_profile.user_id = @user.id
        @seller_profile.source = "seller_website"
        @seller_profile.seller_website_id = @seller_website.id
        @fields.force_submit = true
        @fields.force_zip_not_submit = true unless params['fields']['zip_code'].blank? 
        @fields.force_address_not_submit = true unless params['fields']['property_address'].blank?
        if @seller_profile.valid? && @fields.valid?
          @seller_profile.save!
          @fields.seller_profile_id = @seller_profile.id
          @fields.save!
          seller_sequence = assign_responder_seq_to_the_seller_profile
          notification_email =  SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_sequence, "1", seller_sequence.sequence_name)
          Resque.enqueue(SellerAssignSequenceNotificationWorker, seller_sequence.id, @seller_profile.id)
          engagement_note = @fields.seller_engagement_infos.create(:subject => notification_email.email_subject, :description => notification_email.email_body, :note_type => "Email" )
          redirect_to :action => "new_seller_step_3", :permalink_text => params["permalink_text"], :id => @fields.id
        else
          if params[:commit]=='Next'
          render :action => "new_seller", :permalink_text => params["permalink_text"], :layout=>true
          else
          @country = params[:fields][:country]
          @state = params[:fields][:state]
          render :action => "seller_web_page", :permalink_text => params["permalink_text"], :layout=>true
          end
        end
      else
        redirect_to :controller=>:home,:action=>:index
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def new_seller_step_3
    render :file => REI_404_PAGE and return if params['id'].nil?
  end

  def create_seller_step_3_info
    begin
      if request.post?
        render :file => REI_404_PAGE and return if params['id'].nil?
        @fields = SellerPropertyProfile.find_by_id(params['id'])
        render :file => REI_404_PAGE and return if @fields.blank?
        @fields.force_submit = true
        @fields.update_attributes(params['fields'])
        @fields.save!
        Resque.enqueue(InvestorNotificationNewSellerLeadWorker, @fields.id, @user.id)
        redirect_to :action => "thank_you_page", :permalink_text => params["permalink_text"]
      else
        redirect_to :controller=>:home,:action=>:index
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def privacy_policy
  end

  def terms_of_use
  end

  def thank_you_page
  end

  def assign_responder_seq_to_the_seller_profile
    seller_notification = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",@user.id, SellerResponderSequence::SEQUENCE_SERIES[1]])
    seller_notification = SellerResponderSequence.create( :user_id => @user.id, :sequence_name => SellerResponderSequence::SEQUENCE_SERIES[1], :active => true) if seller_notification.nil?
    seq_assign_to_seller = ResponderSequenceAssignToSellerProfile.create(:seller_property_profile_id => @fields.id, :seller_responder_sequence_id => seller_notification.id, :mail_number => 1)
    return seller_notification
  end

  def re_agents
    
  end

  def submit_investor_comments
    @seller_investor_comment = SellerInvestorComment.new
    unless params[:seller_investor_comment].blank?
      @seller_investor_comment.from_hash(params[:seller_investor_comment])
      if @seller_investor_comment.valid?
        Resque.enqueue(InvestorNotificationNewCommentWorker, @seller_website.id, params[:seller_investor_comment][:name], params[:seller_investor_comment][:email], params[:seller_investor_comment][:comment] )
        flash[:notice] = "Your comment is successfully Sent."
        @seller_investor_comment = nil
        redirect_to :action => "re_agents"
      else
        render :action => "re_agents"
      end
    else
      render :action => "re_agents"
    end
  end

  private

  def check_seller_permalink
    @seller_website = SellerWebsite.find_by_active_permalink(params[:permalink_text])

    if !@seller_website.blank? && @seller_website.seller_magnet
      @seller_magnet = @seller_website
      @user = @seller_magnet.user
      @color = @seller_magnet.seller_magnet_color
      render :template => "amps_magnet/sp_1", :layout => false
    end
  
    if  !@seller_website.blank? && check_host_name(request.host.to_s,@seller_website)
      get_investor_detail
      return true
    else
      render :file => REI_404_PAGE
      return
    end
  end

  def get_investor_detail
    @user = @seller_website.user
    @user_company_image = @user.user_company_image
    @user_company_info  = @user.user_company_info
  end
  
  def check_host_name(host_name,seller_website)
    return true
    # ignoring the check to differentiate between need2sell and sell2house
    #     reim_url = REIMATCHER_URL.to_s.gsub("http://","").gsub("/","").gsub(":3000","")
    #     return  (clean_www(host_name) == clean_www(seller_website.my_website.domain_name) || host_name == reim_url) 
  end

  def clean_www ( url )
    return url.to_s.gsub("www.","")
  end

end
