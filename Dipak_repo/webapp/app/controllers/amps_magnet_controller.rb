class AmpsMagnetController < ApplicationController
  layout "amps_magnet"
 
  before_filter :check_permalink, :except => [:seller_magnet_example]

  def privacy_policy
    render :layout => false
  end

  def terms_of_use
    render :layout => false
  end

  def sp_1
    if params[:id]
      @seller_profile = SellerProfile.find(params[:id])
      @seller_property = @seller_profile.seller_property_profile[0] if @seller_profile
    end
    render :layout => false
  end

  def seller_magnet_example
    render :layout => 'application'
  end

  def create_cold_lead
    if params[:seller_profile_id]
      redirect_to :action => "sp_2", :permalink_text => params[:permalink_text], :id => params[:seller_profile_id]
    elsif params[:seller_profile] && params[:seller_property]
      begin
        profile_params = params[:seller_profile].merge({:seller_website_id => @seller_magnet.id, :source => 'seller_magnet', :amps_cold => true})
        seller_profile = @seller_magnet.user.seller_profiles.new(profile_params)
        seller_property = seller_profile.seller_property_profile.build(params[:seller_property].merge({:notification_email => seller_profile.email, :property_type => "single_family"}))
        
        seller_property.force_submit = true
        if seller_profile.valid? && seller_property.valid?
          seller_profile.save!
          seller_property.seller_profile_id = seller_profile.id
          seller_property.save!
          send_cold_lead_notifications(seller_profile, seller_property)
          redirect_to :action => "sp_2", :permalink_text => params[:permalink_text], :id => seller_profile.id
        else
          redirect_to :action => "sp_1" and return
        end
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        return redirect_to :action => "sp_1"
      end
    else
      return redirect_to :action => "sp_1"
    end
  end

  def sp_2
    @seller_profile = SellerProfile.find(params[:id])
    cold_lead = @seller_profile.seller_property_profile[0]
    @matches = MatchingEngine.buyer_matches(cold_lead)
    render :layout => false
  end

  def create_hot_lead
    seller_profile = SellerProfile.find(params[:seller_profile_id])
    seller_property = seller_profile.seller_property_profile[0]
    if seller_property.property_address.blank?
      begin
        seller_profile.attributes = params[:seller_profile]
        seller_property.attributes = params[:seller_property]
        seller_property.force_submit = true
        if seller_profile.valid? && seller_property.valid?
          seller_profile.save!
          seller_property.save!
          if params["marketing_release"] || params["marketing_release"] == "on"
            create_and_publish_profile(seller_property)
          end
          send_hot_lead_notifications(seller_profile, seller_property)
          redirect_to :action => "thank_you", :permalink_text => params[:permalink_text]
        else
          redirect_to :action => "sp_2" and return
        end
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        redirect_to :action => "sp_2" and return
      end
    else
      redirect_to :action => "thank_you", :permalink_text => params[:permalink_text]
    end
  end
  
  def thank_you
    render :layout => false
  end

  private

  def create_and_publish_profile property
    params = {}
    ['zip_code', 'beds', 'baths', 'min_mon_pay', 'property_type', 'square_feet', "property_address"].each do |x|     
      params[x] = property.send(x).to_s
    end

    if zip = Zip.find_by_zip(params['zip_code'])    
      fields = ProfileFieldForm.create_form_for('owner')
      fields.from_hash(params)
      fields.contract_end_date = Time.now + 180.days
      fields.privacy = "private"
      fields.description = String.new
      fields.investment_type_id = 1
      fields.min_dow_pay = 0.0
      fields.state = zip.state
      fields.country = zip.country

      if fields.valid? && fields.valid_for_property_type?
        profile = Profile.new
        profile.profile_fields = fields.to_profile_fields
        profile.user = @user
        profile.profile_type = ProfileType.find_by_permalink('owner')
        profile.investment_type_id = 1
        profile.generate_name
        profile.zip_code = params[:zip_code]
        profile.save!
        log_activity(:activity_category_id=>'cat_prof_created', :user_id => @user.id, :profile_id => profile.id, :session_id => request.session_options[:id], :profile_name => profile.profile_name)
        SellerPropertyProfile.save_seller_lead_mapping(property.id, profile.id)
        property.seller_engagement_infos.create(:description => "Property posted to Marketplace", :note_type => "Action" )
      end
    end
  end
  
  def check_permalink
    @seller_magnet = SellerWebsite.active_seller_magnet(params[:permalink_text])[0]
    unless @seller_magnet
      render :file => REI_404_PAGE
      return
    end    
    @user = @seller_magnet.user
    @color = @seller_magnet.seller_magnet_color
  end

  def send_cold_lead_notifications(seller_profile, seller_property)
    UserNotifier.deliver_investor_cold_lead_notification(@user, seller_profile, seller_property)
    seller_sequence = SellerResponderSequence.create_squence_and_assign_for_seller(@user.id, SellerResponderSequence::SEQUENCE_SERIES[8], seller_property.id)
    SellerAssignSequenceNotificationWorker.perform(seller_sequence.id, seller_profile.id)
    notification_email =  SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_sequence, "1", seller_sequence.sequence_name)
    seller_property.seller_engagement_infos.create(:subject => notification_email.email_subject, :description => notification_email.email_body, :note_type => "Email")
  end

  def send_hot_lead_notifications(seller_profile, seller_property)
    UserNotifier.deliver_investor_hot_lead_notification(@user, seller_profile, seller_property)
    seller_sequence = SellerResponderSequence.create_squence_and_update_for_seller(@user.id, SellerResponderSequence::SEQUENCE_SERIES[7], seller_property.id)
    SellerAssignSequenceNotificationWorker.perform(seller_sequence.id, seller_profile.id)
    notification_email = SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_sequence, "1", seller_sequence.sequence_name)
    seller_property.seller_engagement_infos.create(:subject => notification_email.email_subject, :description => notification_email.email_body, :note_type => "Email")
  end
end
