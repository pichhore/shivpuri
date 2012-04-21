class ProfileViewController < ApplicationController
  
  before_filter :login_required
  before_filter :load_profile
  before_filter :load_target_profile
  before_filter :check_profile_ownership

  layout "application"
  
  #Changed find to find_by_id since it is breaking the app. I think this needs more refractor
  def show
    @retail_buyer_profile = Profile.find_by_id(params[:retail_buyer_profile]) if(params[:retail_buyer_profile])
    if @profile.id != @target_profile.id
      begin
        @profile_view = ProfileView.new
        @profile_view.profile = @target_profile
        @profile_view.viewed_by_profile = @profile
        @profile_view.save!
      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        msg = "Error saving a ProfileView. This message has been logged but will not impact the user. Details: "+e.to_s
        logger.error(msg)
        puts(msg)
      end
    end
    if @profile.country == "US" and @target_profile.public_profile?
      # center map on address
      # LATLNG
      center_latlng = @target_profile.owner? ? @target_profile.latlng : nil
      # center_latlng = @target_profile.owner? ? ZipCodeMap.lookup_latlng(@target_profile.geocoder_address) : nil

      if center_latlng == nil then
        @map = ZipCodeMap.prepare_map(@target_profile.zip_code, :suppress_controls => true, :zoom_level => 11, :map_type_init => GMapType::G_HYBRID_MAP )
      else
        @map = ZipCodeMap.prepare_map(@target_profile.zip_code, :suppress_controls => true, :zoom_level => 17, :center_latlng => center_latlng, :map_type_init => GMapType::G_HYBRID_MAP )
        @marker_overlays = ZipCodeMap.prepare_marker_overlays([@target_profile], :context_profile=>@profile)
      end
    else
      @map = nil
    end

    # determine next and prev profile ids
    # skip in conversation view; we could try to page through in the order the message recipients are showing
    # but that's probably overkill
    if params['ref'] != 'conv'
      @prev_profile_id, @next_profile_id, @previous_profile_page, @next_profile_page = find_prev_next_profile_ids(params, false)
      params[:own_buyer] = true
    end
    
    # indicate that we're using popups on thumbnails
    @uses_yui_lightbox = true
    
    respond_to do |format|
      format.html { render :action => "show_"+@target_profile.profile_type.permalink_to_generic_page }
      format.xml  { render :xml => @target_profile.to_xml }
    end
  end

end