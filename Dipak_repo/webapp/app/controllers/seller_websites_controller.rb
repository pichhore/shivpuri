
class SellerWebsitesController < ReiWebsitesController
  before_filter :login_required
  layout "application"
  uses_yui_editor
  uses_yui_editor(:only=>[:new,:set_up,:step2,:edit,:update,:create])

  before_filter do  |controller|
    controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc2_type]])
  end

  before_filter :is_seller_profile_exists, :only => ["update_seller_profile", "update_seller_property_profile", "update_seller_financial_infos", "create_seller_engagement_note", "update_seller_sequence", "save_scratch_pad_info", "confirm_archive_seller_lead[]", "delete_seller_note", "step1_for_generate_contract", "step2_for_generate_contract","step3_for_generate_contract", "download_contract_pdf"]

  before_filter :set_site_type

  before_filter :is_seller_property_profile_exists, :only => ["update_seller_profile", "update_seller_property_profile", "update_seller_financial_infos", "create_seller_engagement_note", "update_seller_sequence", "save_scratch_pad_info", "delete_seller_note","step1_for_generate_contract", "step1_for_generate_contract","step2_for_generate_contract","step3_for_generate_contract", "download_contract_pdf"]

  before_filter :get_seller_profile_and_seller_property_profile, :only => ["add_new_seller", "seller_lead_full_page_view", "property", "repairs", "engagement_tab", "financial_tab", "add_seller_notes", "seller_note_full_page_view", "scratch_pad"]

  def index
    @my_websites = current_user.my_websites.find(:all, :conditions => [ " site_type in (?)",[ @website_type.capitalize + "Website", @website_type.capitalize + "WebPage"]] ) || []
  end

  def auto_complete_for_profile_contract_my_buyer
     re = Regexp.new("^#{params[:profile_contract][:my_buyer]}", "i")
     @customers = Profile.find_by_sql("select * from profiles where user_id = '#{current_user.id}' and id in (select profile_id from profile_field_engine_indices where is_owner = false and status = 'active')").collect(&:private_display_name).uniq.select { |org| org.match re }
#                @customers = User.find(:all).collect(&:first_name).select { |org| org.match re }
    render :layout => false
  end

  def show
    redirect_to :action=>:set_up
  end

  def new
    redirect_to :action=>:set_up
  end

  def edit
    @seller_website = SellerWebsite.find_by_id(params[:id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @seller_website.blank?
    @domain_name = @seller_website.my_website.domain_name
     set_link_to_paste
  end

# Need to make correction on association based
  def set_up
    seller_website = current_user.seller_website
    @seller_website = seller_website.nil? ? SellerWebsite.new : seller_website
    render :action=>:new
  end

  def create
   @seller_website = current_user.seller_websites.build(params[:seller_website])
    my_website = @seller_website.build_my_website(:domain_name => params[:domain_name],:user_id=>current_user.id)
    if @seller_website.seller_magnet
      @seller_website.meta_title = SellerWebsite::META_TITLE
      @seller_website.meta_description = SellerWebsite::META_DESCRIPTION
    end

    if @seller_website.save
      my_website.save
      flash[:notice] = 'SellerWebsite was successfully created.'
      enter_domain_name if (params[:seller_website][:domain_type] == MyWebsiteForm::DOMAIN_TYPE[:having] || params[:seller_website][:domain_type] == MyWebsiteForm::DOMAIN_TYPE[:buying])
      #redirect_to :action=>:set_up
      redirect_to :action=>:index 
    else
      # Hack for IE .. multiple YUI editor are causing the POST request to be fired multiple times , so hacking for now .
      if flash[:notice] == 'SellerWebsite was successfully created.'
        flash[:notice] = 'SellerWebsite was successfully created.'
        return redirect_to :action=>:index
      end
      render :action=>:step2
    end
  end

  def update

    @seller_website = SellerWebsite.find_by_id(params[:id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @seller_website.blank?
    if @seller_website.domain_type ==  MyWebsiteForm::DOMAIN_TYPE[:having]
      params[:seller_website][:permalink_text] = params[:seller_website][:my_website_attributes][:domain_name].to_s.delete"./"
    end

    params[:seller_website][:permalink_text] = params[:seller_website][:permalink_text].downcase

    if @seller_website.update_attributes(params[:seller_website])
#       @seller_website.update_property_profile unless @seller_website.seller_property_profile.blank?
      flash[:notice] = 'SellerWebsite was successfully updated.'
      enter_domain_name if (@seller_website.domain_type == MyWebsiteForm::DOMAIN_TYPE[:having] || @seller_website.domain_type == MyWebsiteForm::DOMAIN_TYPE[:buying])
      redirect_to :action=>:index
    else
      @domain_name = params[:domain_name]
      @link_to_paste = params[:link_to_paste]
      render :action=>:edit
    end
  end

  def destroy
    @seller_website = SellerWebsite.find_by_id(params[:id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @seller_website.blank?
    domain_type = @seller_website.domain_type
    @seller_website.destroy
    enter_domain_name if (domain_type == MyWebsiteForm::DOMAIN_TYPE[:having] || domain_type == MyWebsiteForm::DOMAIN_TYPE[:buying])
   flash[:notice]= "Website deleted successfully."
   redirect_to :action => :index
  end

=begin
  #Seller Website Setup process
  def step1
    @my_website_form = MyWebsiteForm.new
  end
=end

  def step2
      @my_website_form = MyWebsiteForm.new
      @my_website_form.from_hash(params[:my_website_form])
      if @my_website_form.valid?
          if params[:my_website_form][:type] == MyWebsite::WEB_SITE_TYPE[:seller]
            @seller_website = SellerWebsite.new
            set_seller_website_fields
         end
        # In future will add the buyer web site and need to check for that also.
      else
          render :action=>:step1
      end
  end

  def add_new_seller
    session["profile_id"] = params[:profile_id]
  end

  def create_new_seller_profile
     begin
      @seller_profile = current_user.seller_profiles.new(params[:seller_profile])
      @seller_property = @seller_profile.seller_property_profile.build(params[:seller_property])
      @seller_profile.seller_website_id = current_user.seller_websites.first.id unless current_user.seller_websites.blank?
      @seller_property.force_submit = true
      if @seller_profile.valid? and @seller_property.valid?
        @seller_profile.save!
         @seller_property.save!
        create_seller_info_mapping_and_profile unless session["profile_id"].blank?
        create_or_update_seller_owner
        seller_sequence = assign_responder_seq_to_the_seller_profile
#         send_seller_responder_sequence_notification(seller_sequence) if session["profile_id"].blank?
        flash[:notice] = 'New Seller was successfully created.'
        session["profile_id"] = nil unless session["profile_id"].blank? 
        return redirect_to :action => "seller_lead_full_page_view", :id => @seller_profile.id
      else
        render :action => "add_new_seller" and return
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      return redirect_to :action => "add_new_seller"
    end
  end

  def seller_lead_management
    begin
      @sequence_type = params[:sequence_type]
      search_string = params[:seller_profile_search]
      if !search_string.blank?
        searched_profiles = search_for_seller_profile(search_string)
        @seller_profiles = searched_profiles.paginate :page => params[:page], :per_page => 10
      elsif ["sequence_one", "sequence_three", "sequence_two", "sequence_four", "do_not_call", "no_sequence"].include?(params[:sequence_type])
        filter_by_sequence
      else
        @seller_profiles = current_user.seller_profiles.paginate(:all,:conditions=>["is_archive=0"], :order => "created_at desc", :page => params[:page], :per_page => 10)
      end
    render :partial=>"seller_lead_management",:layout=>false if request.xhr?
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def seller_lead_full_page_view
    session[:scratch_pad_note] = nil if session[:seller_lead_id] != params[:id]
    @seller_profile.seller_property_profile[0].update_attribute(:is_new, false) unless @seller_profile.seller_property_profile[0].blank?
    seller_owners = @seller_property.seller_property_owners
    get_seller_owner(seller_owners)
    @seller_notification = @seller_property.responder_sequence_assign_to_seller_profile.seller_responder_sequence unless @seller_property.responder_sequence_assign_to_seller_profile.blank?
    @is_profile_has_bounced_email_address = BouncedEmail.find_bounced_email_address(@seller_profile.email.to_s)
  end
  
  def property
  end

  def repairs
  end

  def engagement_tab
    @seller_engagement_infos = @seller_property.seller_engagement_infos.paginate(:all, :order => "created_at desc",:page => params[:page],:per_page => 10)
  end

  def financial_tab
    @seller_financial_loan_one_info, @seller_financial_loan_two_info = get_seller_financial_info(SellerFinancialInfo::FINANCIAL_LOAN_NUMBER["loan_one"]), get_seller_financial_info(SellerFinancialInfo::FINANCIAL_LOAN_NUMBER["loan_two"])
  end

  def update_seller_profile
    begin
      render :file => "#{RAILS_ROOT}/public/404.html" and return if params[:seller_profile].blank?
      if @seller_profile.update_attributes(params[:seller_profile])
        create_or_update_seller_owner
        flash[:notice] = 'Seller info updated successfully'
        redirect_to :action=>"seller_lead_full_page_view",:id=>@seller_profile.id
      else
        render :action=>"seller_lead_full_page_view",:id=>@seller_profile.id
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def update_seller_property_profile
    begin
      render :file => "#{RAILS_ROOT}/public/404.html" and return if params[:seller_property].blank?
      if @seller_property.update_attributes(params[:seller_property])
  
        @seller_property.update_property_profile_after_updating_seller_property unless @seller_property.profile.blank?
        flash[:notice] = 'Seller info updated successfully'
        get_redirect_to_action_for_property_profile
      else
        get_render_action_for_property_profile
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def update_seller_financial_infos
    params_loan_one = params[:seller_financial_loan_one_info]
    params_loan_two = params[:seller_financial_loan_two_info]
    render :file => "#{RAILS_ROOT}/public/404.html" and return if params_loan_one.blank? && params_loan_two .blank?
    @seller_financial_infos = @seller_property.seller_financial_infos
    create_or_update_financial_info(params_loan_one, params_loan_two)
    if @is_valid_fin_info
      flash[:notice] = 'Seller financial info updated successfully'
      redirect_to :action=>"financial_tab",:id=>@seller_profile.id
    else
      render :action=>"financial_tab",:id=>@seller_profile.id
    end
  end

  def create_or_update_financial_info(params_loan_one, params_loan_two)
    begin
      if @seller_financial_infos.blank?
        seller_financial_info_one = create_seller_financial_info params_loan_one
        seller_financial_info_two = create_seller_financial_info params_loan_two if @is_valid_fin_info
      else
        seller_financial_info_one = update_seller_financial_information params_loan_one
        seller_financial_info_two = update_seller_financial_information params_loan_two if @is_valid_fin_info
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def create_seller_financial_info(params_hash)
    seller_financial_info = @seller_property.seller_financial_infos.new(params_hash)
    if seller_financial_info.save!
      @is_valid_fin_info = true
    else
      @is_valid_fin_info = false
    end
  end

  def update_seller_financial_information(params_hash)
    seller_financial_info = @seller_property.seller_financial_infos.find(:first, :conditions => ["financial_loan_number=?",params_hash["financial_loan_number"]])
    if seller_financial_info.blank?
      seller_financial_info = create_seller_financial_info params_hash
    elsif seller_financial_info.update_attributes(params_hash)
      @is_valid_fin_info = true
    else
      @is_valid_fin_info = false
    end
  end

  def add_seller_notes
    @seller_engagement_note = @seller_property.seller_engagement_infos.new()
  end

  def create_seller_engagement_note
    render :file => "#{RAILS_ROOT}/public/404.html" and return if params[:seller_profile].blank? && params[:seller_engagement_note].blank?
    begin
      @seller_engagement_note = @seller_property.seller_engagement_infos.new(params[:seller_engagement_note])
      if @seller_engagement_note.save!
        flash[:notice] = 'Seller Note created successfully'
        redirect_to :action=>"engagement_tab",:id=>@seller_profile.id
      else
        render :action => "add_seller_notes", :id=>@seller_profile.id
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def seller_note_full_page_view
    @seller_engagement_note = @seller_property.seller_engagement_infos.find_by_id(params[:seller_note_id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @seller_engagement_note.blank?
  end

  def delete_seller_note
    begin
      @seller_engagement_note = @seller_property.seller_engagement_infos.find_by_id(params[:seller_note_id])
      render :file => "#{RAILS_ROOT}/public/404.html" and return if @seller_engagement_note.blank?
      @seller_engagement_note.destroy
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    redirect_to :controller=>'seller_websites', :action=>'engagement_tab', :id=>params[:id]
  end

  def update_seller_sequence
    begin
      find_or_create_seller_responder_sequence
      seq_assign_to_seller = @seller_property.responder_sequence_assign_to_seller_profile
      if seq_assign_to_seller.blank?
        seq_assign_to_seller = ResponderSequenceAssignToSellerProfile.create(:seller_property_profile_id => @seller_property.id, :seller_responder_sequence_id => @seller_notification.id, :mail_number => 1)
      else
        @seller_property.update_attribute( :responder_sequence_subscription, true )
        seq_assign_to_seller.update_attributes(:seller_responder_sequence_id => @seller_notification.id, :mail_number => 1)
      end
      seller_sequence = seq_assign_to_seller.seller_responder_sequence
      unless ["none", "do_not_call", "no_sequence"].include?(params[:seller_notification][:sequence_name])
        send_seller_responder_sequence_notification(seller_sequence)
      end
      redirect_to :action=>"seller_lead_full_page_view", :id=>@seller_profile.id
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def scratch_pad
    render :layout=>false
  end

  def set_scratch_pad_note
    session[:scratch_pad_note] = params[:note_text] if session[:scratch_pad_note_when_discard] != params[:note_text]
     session[:seller_lead_id] = params[:seller_lead_id]
     session[:scratch_pad_note_when_discard] = nil
#      session[:scratch_pad_subject] = params[:subject]
#      session[:scratch_pad_tag] = params[:tag]
     render :text => 'ok'
  end

  def discard_scratch_pad_note_lightbox
    session[:scratch_pad_note] = nil
    session[:scratch_pad_note_when_discard] = params[:note_text]
    render :text => false
  end

  def save_scratch_pad_info
    begin
      @seller_engagement_note = @seller_property.seller_engagement_infos.create(params[:seller_engagement_info])
      session[:scratch_pad_note] = nil
      render :text => false
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Error trying to redirect. Please try again later or contact support",exp) and return
    end
  end


  def seller_lead_info
   begin
    profile =  Profile.find(params[:id])
    if !profile.profile_field_engine_index.blank? and profile.profile_field_engine_index.property_type == "single_family"
      profile_seller_mapping = profile.profile_seller_lead_mapping
      if profile_seller_mapping.blank?
        redirect_to :action => "add_new_seller", :profile_id=>params[:id]
      else
        redirect_to  seller_lead_full_page_view_seller_website_path(:id => profile_seller_mapping.seller_profile_id)
      end
    else
      flash[:notice] = ' Seller lead linking is only available for Single Family property at the moment.'
      redirect_to  profile_path(profile)
    end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def archive_seller_lead
    profile_ids = params[:archive_seller_profiles].split(',')
    profile_ids.each do |archive_seller_profile_id|   
      begin
        @seller_profile = SellerProfile.find_by_id(archive_seller_profile_id)
        render :file => "#{RAILS_ROOT}/public/404.html" and return if @seller_profile.blank?

        if params[:seller_profile][:delete_reason].blank? or !SellerProfile::SELLER_PROFILE_DELETE_REASON.include?(params[:seller_profile][:delete_reason])
          redirect_to :action => "confirm_archive_seller_lead", :id => "1", :deletable_profile_ids => params[:archive_seller_profiles], :page => "2" and return
        end

        @seller_lead_mapping = ProfileSellerLeadMapping.find_by_seller_profile_id(@seller_profile.id)
        @profile = Profile.find_by_id(@seller_lead_mapping.profile_id) unless @seller_lead_mapping.blank?
        @profile.destroy unless @profile.blank?
 
        if params[:seller_profile][:delete_reason] == SellerProfile::SELLER_PROFILE_DELETE_REASON[2]
          seller_profile_name = "#{@seller_profile.first_name} #{@seller_profile.last_name}".rstrip

          # @seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.destroy
          @seller_profile.destroy
          ActivityLog.create!({ :activity_category_id=>'cat_seller_prof_deleted', :user_id=>current_user.id, :description => SellerProfile::SELLER_PROFILE_DELETE_REASON_NAME[params[:seller_profile][:delete_reason]], :seller_profile_name => seller_profile_name})
        else
          @seller_profile.update_attributes(:is_archive=>1, :delete_reason =>params[:seller_profile][:delete_reason], :delete_comment =>params[:seller_profile][:delete_comment])
          
          log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND seller_profile_id = ? ", 'cat_seller_prof_deleted', @seller_profile.id])
          
          ActivityLog.create!({ :activity_category_id=>'cat_seller_prof_deleted', :user_id=>current_user.id, :seller_profile_id=>@seller_profile.id, :description => SellerProfile::SELLER_PROFILE_DELETE_REASON_NAME[params[:seller_profile][:delete_reason]]}) if !log_entry_already_found
        end

        flash[:notice] = "Seller lead archived successfully."
      rescue Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      end
    end
    redirect_to :action => :seller_lead_management, :page => params[:page]
  end

  def confirm_archive_seller_lead
    if !params["deletable_profile_ids"].blank?
      profile_ids = params[:deletable_profile_ids].split(',')
      seller_profiles = []
      profile_ids.each{|x| seller_profiles << SellerProfile.find_by_id(x)}
      @seller_names = String.new
      seller_profiles.each do |sp| 
         @seller_names += ", " unless @seller_names.blank?
         @seller_names += "#{sp.first_name} #{sp.last_name}".rstrip
      end
      @seller_profile_ids = params[:deletable_profile_ids]
      render :file => "#{RAILS_ROOT}/public/404.html" and return if seller_profiles.empty?
    else
      flash[:error] = "Please select one seller lead to archive."
      redirect_to :action=>:seller_lead_management, :page => params[:page]
    end
  end

  def get_sellers_for_suggestion
    @sellers = current_user.seller_profiles.find(:all, :conditions => ['first_name LIKE ? or last_name LIKE ? ', "#{params[:search]}%","#{params[:search]}%"], :limit => 10)
    render :layout => false   
  end

  def assign_existing_seller_lead
     begin
      if !params[:seller].blank? and !params[:id].blank?
        @seller_profile = current_user.seller_profiles.find(params[:seller])
        session["profile_id"] = params[:id]
        if !@seller_profile.blank? and @seller_profile.seller_property_profile.blank? 
#         @seller_profile = current_user.seller_profiles.find(params[:seller])
          @seller_property = @seller_profile.seller_property_profile.build
          if @seller_property.save 
            create_seller_info_mapping_and_profile 
            session["profile_id"] = nil unless session["profile_id"].blank?
            flash[:notice] = 'Seller was successfully assigned' 
            redirect_to  seller_lead_full_page_view_seller_website_path(:id => @seller_profile.id)
          end
        else
          flash[:notice] = 'Seller has already assigned a property' 
          redirect_to  seller_lead_info_seller_website_path
        end
      else
        flash[:notice] = 'please select a seller lead'
        redirect_to  seller_lead_info_seller_website_path(:id => session[:profile_id])
      end
      rescue  Exception => exp
       ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
     end
  end

  def unassign_seller_lead
    get_seller_and_seller_property_profile params[:id]
    mapping = @seller_property.profile_seller_lead_mapping
    if mapping.destroy
      new_seller_property = @seller_profile.seller_property_profile.build
      new_seller_property.force_submit = true
      new_seller_property.save
    end
   redirect_to seller_lead_full_page_view_seller_website_path(@seller_profile)
#    redirect_to :controller => :seller_websites, :action => :property, :id => @seller_profile.id
  end

  def link_to_property_profile
    get_seller_and_seller_property_profile params[:id]
    if @seller_property.valid? 
      redirect_to :controller=>"profiles", :action=>"new", :id=>"owner",:seller_property_profile_id=>@seller_property.id
    else
       render :action => "property",:id => @seller_profile.id  
    end
  end

  def step1_for_generate_contract
    if @seller_property.valid? 
      unless @seller_property.profile_contract.blank?
          redirect_to step2_for_generate_contract_seller_website_path(@seller_profile) 
#          @profile_contract =@seller_property.profile_contract
#          @seller= @profile_contract.contract_seller_type.code 
#          @buyer = @profile_contract.contract_buyer_type.code
#          @profile_contract.my_buyer = @profile_contract.contract_my_buyer.private_display_name
      else
        @profile_contract = ProfileContract.new 
      end
    else
       flash[:notice] = "Please update your property first"
       redirect_to :action => "property",:id => @seller_profile.id  
    end
  end

  def step2_for_generate_contract
    if request.post?
      @profile_contract = !@seller_property.profile_contract.blank? ? @seller_property.profile_contract : ProfileContract.new
      @profile_contract.seller_write_in = params[:profile_contract][:seller_write_in]
      @profile_contract.buyer_write_in = params[:profile_contract][:buyer_write_in]
#        @profile_contract = ProfileContract.new(params[:profile_contract])
      @profile_contract.seller_property_profile_id = @seller_property.id
      @seller= params[:profile_contract][:contract_seller_type_id]
      @buyer = params[:profile_contract][:contract_buyer_type_id]
      if @buyer == "MB" and !@buyer.blank?
        selected_buyer = current_user.profiles.find(:first, :conditions => ["private_display_name = ?",params[:profile_contract][:my_buyer]])
        @profile_contract.my_buyer = selected_buyer.blank? ? nil : selected_buyer.id
      end
      seller_type = ContractSellerType.find_by_code(@seller) unless @seller.blank?
      buyer_type = ContractBuyerType.find_by_code(@buyer) unless @buyer.blank?
      @profile_contract.contract_seller_type_id = seller_type.blank? ? nil : seller_type.id.to_i 
      @profile_contract.contract_buyer_type_id = buyer_type.blank? ? nil : buyer_type.id.to_i 
      if @profile_contract.save
        @contract_content = get_property_contract_content 
      else
        render :action => "step1_for_generate_contract", :id => @seller_profile.id
#         redirect_to step1_for_generate_contract_seller_website_path(@seller_profile)
      end  
    else
      @profile_contract = @seller_property.profile_contract
      unless @profile_contract.blank?
        @contract_content = update_property_contract_content
      else
        redirect_to step1_for_generate_contract_seller_website_path(@seller_profile)
      end
    end
  end

  def step3_for_generate_contract
    @profile_contract = @seller_property.profile_contract
    unless @profile_contract.blank?
      return unless request.post?
      unless @profile_contract.blank?
        contract_content = get_property_original_content(params[:profile_contract][:contract])
        @profile_contract.update_attribute(:contract,contract_content) 
      end
    else
      redirect_to step1_for_generate_contract_seller_website_path(@seller_profile)
    end
  end

  def download_contract_pdf
    @profile_contract = @seller_property.profile_contract
    unless @profile_contract.blank?   
     if params[:email_flag] == "email"    	
	if request.post?
	 unless params[:report][:email].blank?
       html_content = render_to_string(:action => 'print_contract', :layout => false)
	  pdf_convert = PDFKit.new(html_content, :margin_right => '0.10in',:margin_left => '0.10in',:margin_top => '0.20in')
	  file=pdf_convert.to_pdf
       contract_name = "#{get_property_state.name}-Contract on #{Time.now.to_s}.pdf"
	  project_filr = File.new("#{RAILS_ROOT}/tmp/"+contract_name.to_s,'w+')
	  project_filr.write(file)
        project_filr.close
	  @input_emails = params[:report][:email]
	  emails_array = params[:report][:email].split(',')
	  flag = false
	  emails_array.each do |mail|
	   @sent_report = SentReport.new
	   @sent_report.email = mail.strip
	    break flag = true unless @sent_report.valid?
	  end
	  unless flag
        emails_array.each do |email|
            Resque.enqueue(SendPropertyContractToOutOfReimWorker, email, contract_name)
#                UserNotifier.deliver_send_property_contract_to_out_of_reim(email, contract_name)
          @seller_property.seller_engagement_infos.create(:note_type => "Email", :description => "Sent contract to #{email}", :subject => "Sent Contract")
        end
#         File.delete("#{RAILS_ROOT}/tmp/"+contract_name) if File.exist?("#{RAILS_ROOT}/tmp/"+contract_name)
	  @reload = true
      flash[:notice] = 'Email was successfully sent.'
	  render :action => :send_email_with_contract,:layout => false
	  else
	   render :action => "send_email_with_contract",:layout => false  
	  end
	else
	 @sent_report = SentReport.new
	 @sent_report.valid?
	 #@sent_report.errors.on(:email)
	 render :action => :send_email_with_contract,:layout => false
	end
	else
	render :action => "send_email_with_contract",:layout => false  
	end
    else
        contract_name = "#{get_property_state.name}-Contract.pdf"
      html_content = render_to_string(:action => 'print_contract', :layout => false)
      pdf_convert = PDFKit.new(html_content, :margin_right => '0.10in',:margin_left => '0.10in',:margin_top => '0.20in')
      send_data(pdf_convert.to_pdf,:filename=>contract_name)
      @seller_property.seller_engagement_infos.create(:note_type => "Export Contract", :description => "Export Contract", :subject => "Export Contract")
      end
    else
      redirect_to step1_for_generate_contract_seller_website_path(@seller_profile)
    end
  end

private

  def update_property_contract_content
    if @profile_contract.contract.blank?
      state = get_property_state
      super_contract_integration = SuperContractIntegration.find(:first, :conditions => ["state_id = ?",state.id])
      content = (super_contract_integration.blank?) ? (@profile_contract.contract) : (super_contract_integration.blank? ? "" : super_contract_integration.contract)
    else
      content = @profile_contract.contract
    end
    get_property_original_content(content)
  end

  def get_property_contract_content
    state = get_property_state 
    super_contract_integration = SuperContractIntegration.find(:first, :conditions => ["state_id = ?",state.id])
    content = super_contract_integration.blank? ? @profile_contract.contract : super_contract_integration.contract
    get_property_original_content(content)
  end

  def get_property_state
    zip = Zip.find_by_zip(@seller_property.zip_code)
    State.find_by_state_code(zip.state)
  end

  def get_property_original_content(content)
    unless content.blank?
    seller_first_name = get_property_seller_name_info
    seller_first_name = seller_first_name.blank? ? "Seller First Name" : seller_first_name
    buyer_name_info = get_property_buyer_name_info
    buyer_name_info = buyer_name_info.blank? ? "Buyer First Name" : buyer_name_info
#     seller_first_name = @seller_profile.first_name.blank? ? "Seller First Name" : @seller_profile.first_name
#     seller_last_name = @seller_profile.last_name.blank? ? "Seller Last Name" : @seller_profile.last_name
    seller_property_city = Zip.find(:first, :conditions => ['zip = ?', @seller_property.zip_code]).city
    property_city = seller_property_city.blank? ? "City" : seller_property_city
    investor_first_name = current_user.first_name.blank? ?  "Investor First Name" : current_user.first_name
    investor_last_name = current_user.last_name.blank? ?  "Investor Last Name" : current_user.last_name
    investor_full_name = investor_first_name+" "+investor_last_name  
    seller_lead_created = @seller_profile.created_at.to_date.to_s
    company_name = (!current_user.user_company_info.blank? and !current_user.user_company_info.business_name.blank?) ? current_user.user_company_info.business_name : "Company Name"
    company_email  = (!current_user.user_company_info.blank? and !current_user.user_company_info.business_email.blank?) ? current_user.user_company_info.business_email : "Company Email"
    company_phone = (!current_user.user_company_info.blank? and !current_user.user_company_info.business_phone.blank?) ? current_user.user_company_info.business_phone : "Company Phone"
    company_address = (!current_user.user_company_info.blank? and !current_user.user_company_info.business_address.blank?) ? current_user.user_company_info.business_address :  "Company Address"
    seller_website = @seller_profile.seller_website.blank? ? "" : create_website_url(@seller_profile.seller_website.my_website)
    content.to_s.gsub("{Retail buyer first name}",buyer_name_info).gsub("{seller first name}",seller_first_name).gsub("{seller property city}",property_city).gsub("{date seller lead created}",seller_lead_created).gsub("{Investor first name}",investor_first_name).gsub("{Investor full name}",investor_full_name).gsub("{Company name}",company_name).gsub("{Company address}",company_address).gsub("{Company phone}",company_phone).gsub("{Company email}",company_email).gsub("{investor seller website URL}",seller_website) 
    end
  end
  
  def get_property_seller_name_info
    seller_type = @profile_contract.contract_seller_type.code
    if seller_type == "WI"
      return @profile_contract.seller_write_in
    elsif seller_type == "OWN"
      return (@seller_property.seller_property_owners[0].blank?) ? "" : @seller_property.seller_property_owners[0].owner_name
    else
      return current_user.first_name
    end 
  end

  def get_property_buyer_name_info
    buyer_type = @profile_contract.contract_buyer_type.code
    if buyer_type == "WI"
      return @profile_contract.buyer_write_in
    elsif buyer_type == "MB"
      return @profile_contract.contract_my_buyer.private_display_name
    else
      return current_user.first_name
    end 
  end

  def create_seller_info_mapping_and_profile
    profile = Profile.find(session["profile_id"])
    profile_field = profile.profile_field_engine_index
#     syndicate_field = profile.syndicate_property
    ProfileSellerLeadMapping.create(:profile_id => profile.id  , :seller_profile_id =>@seller_profile.id, :seller_property_profile_id => @seller_property.id)
    @seller_property.update_attributes( :zip_code => profile_field.zip_code, :property_type => profile_field.property_type, :beds => profile_field.beds, :baths => profile_field.baths, :square_feet => profile_field.square_feet, :price => profile_field.price, :units => profile_field.units, :acres => profile_field.acres, :privacy => profile_field.privacy, :property_type_sort_order => profile_field.property_type_sort_order, :has_profile_image => profile_field.has_profile_image, :profile_created_at => profile_field.profile_created_at, :has_features => profile_field.has_features, :has_description => profile_field.has_description, :profile_type_id => profile_field.profile_type_id, :min_mon_pay => profile_field.min_mon_pay, :min_dow_pay => profile_field.min_dow_pay, :contract_end_date => profile_field.contract_end_date, :status => profile_field.status, :notification_email => profile_field.notification_email, :deal_terms => profile_field.deal_terms, :video_tour => profile_field.video_tour, :embed_video => profile_field.embed_video, :notification_phone => profile_field.notification_phone, :property_address => profile.field_value("property_address"), :description => profile.field_value("description"), :garage => profile.field_value("garage"), :stories => profile.field_value("stories"), :neighborhood => profile.field_value("neighborhood"), :natural_gas => profile.field_value("natural_gas"), :electricity => profile.field_value("electricity"), :sewer => profile.field_value("sewer"), :water => profile.field_value("water"), :pool => profile.field_value("pool"), :fencing => profile.field_value("fencing"), :livingrooms => profile.field_value("livingrooms"), :school_elementary => profile.field_value("school_elementary"), :school_middle => profile.field_value("school_middle"), :school_high => profile.field_value("school_high"), :waterfront => profile.field_value("waterfront"), :condo_community_name => profile.field_value("condo_community_name"), :feature_tags => profile.field_value("feature_tags"), :manufactured_home => profile.field_value("manufactured_home"), :house => profile.field_value("house"), :total_actual_rent => profile.field_value("total_actual_rent"), :county => profile.field_value("county"), :barn => profile.field_value("barn"))
  end

  def get_seller_and_seller_property_profile(id)
    @seller_profile = SellerProfile.get_seller_profile_info(id)
    @seller_property = SellerPropertyProfile.get_seller_property_info(@seller_profile)
  end

  def get_seller_financial_info (type)
    return SellerFinancialInfo.get_seller_financial_information(@seller_property, type)
  end

  def get_redirect_to_action_for_property_profile
    redirect_to :action=>"property",:id=>@seller_profile.id if params[:repairs_tab].blank?
    redirect_to :action=>"repairs",:id=>@seller_profile.id unless params[:repairs_tab].blank?
  end

  def get_render_action_for_property_profile
    render :action=>"property",:id=>@seller_profile.id if params[:repairs_tab].blank?
    render :action=>"repairs",:id=>@seller_profile.id unless params[:repairs_tab].blank?
  end

  def send_seller_responder_sequence_notification(seller_sequence)
    notification_email =  SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_sequence, "1", seller_sequence.sequence_name)
    Resque.enqueue(SellerAssignSequenceNotificationWorker, seller_sequence.id, @seller_profile.id)
    engagement_note = @seller_property.seller_engagement_infos.create(:subject => notification_email.email_subject, :description => notification_email.email_body, :note_type => "Email" )
  end
  
  def set_seller_website_fields
    if params[:my_website_form][:domain] == MyWebsiteForm::DOMAIN_TYPE[:reim] 
      @seller_website.permalink_text = params[:my_website_form][:reim_domain_name]==MyWebsiteForm::REIM_DOMAIN_NAME[:second] ? params[:my_website_form][:reim_domain_permalink2] : params[:my_website_form][:reim_domain_permalink1]
      @domain_name = params[:my_website_form][:reim_domain_name]
    elsif params[:my_website_form][:domain] == MyWebsiteForm::DOMAIN_TYPE[:having] 
      @seller_website.permalink_text = params[:my_website_form][:having_domain_name].to_s.delete"./"
      @domain_name = params[:my_website_form][:having_domain_name]
    end
    
    @seller_website.seller_magnet = true if params[:seller_magnet] == "true"
    # Check site type and assign appropriate default texts
    if @seller_website.seller_magnet
      @seller_website.landing_page_headline = SellerWebsite::LANDING_PAGE_HEADLINE
      @seller_website.results_page_copy = SellerWebsite::RESULTS_PAGE_COPY
      @seller_website.results_page_content = SellerWebsite::RESULTS_PAGE_CONTENT
      @seller_website.thankyou_page_headline = SellerWebsite::THANKYOU_PAGE_HEADLINE
      @seller_website.thankyou_page_copy = SellerWebsite::THANKYOU_PAGE_COPY
    else
      @seller_website.meta_title = SellerWebsite::META_TITLE
      @seller_website.meta_description = SellerWebsite::META_DESCRIPTION
      @seller_website.header = SellerWebsite::HEADER_TEXT
      @seller_website.home_page_main_text_1 = SellerWebsite::HOME_PAGE_TEXT1
      @seller_website.home_page_main_text_2 = SellerWebsite::HOME_PAGE_TEXT2
    end
    set_link_to_paste
  end
    
  def set_link_to_paste
    if(@domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:second] || @domain_name==MyWebsiteForm::REIM_DOMAIN_NAME[:first])
      @link_to_paste = @domain_name +"/" + @seller_website.permalink_text 
      return
    else
      @link_to_paste = @domain_name
      return
    end
  end

  def search_for_seller_profile(search_string)
    search = ActsAsXapian::Search.new([SellerProfile, SellerPropertyProfile], search_string, {:limit=>10000000})
    searched_profiles = []
    search.results.each { |result|
    model_name = result[:model].class.name
    profile = model_name == "SellerPropertyProfile" ? result[:model].seller_profile : result[:model]
    searched_profiles << profile if !profile.nil? and profile.user_id == current_user.id and !profile.is_archive
    }
    return searched_profiles
  end

  def is_user_have_seller_website
    get_seller_and_seller_property_profile(id)
    if current_user.seller_websites.blank?
      flash[:notice] = 'Create your seller website first.'
      render :action => "seller_lead_full_page_view" and return
    end
  end

  def is_seller_profile_exists
    @seller_profile = SellerProfile.find(:first, :conditions => ["id = ?", params[:id]])
    if @seller_profile.blank?
      get_seller_and_seller_property_profile params[:id]
      flash[:notice] = 'Create your seller profile first.'
      redirect_to :action => "add_new_seller" and return
    end
  end

  def find_or_create_seller_responder_sequence
    @seller_notification = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",current_user.id,params[:seller_notification][:sequence_name]])
    if @seller_notification.nil?
      @seller_notification = SellerResponderSequence.new(params[:seller_notification])
      @seller_notification.user_id = current_user.id
      @seller_notification.active = true
      @seller_notification.save
    end
  end

   def filter_by_sequence
     seller_profiles = current_user.seller_profiles
     total_seller_profiles = []
     seller_profiles.each do |seller_profile|
       next if seller_profile.is_archive
       next if seller_profile.seller_property_profile[0].blank?
       next if seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.blank?
       if params[:sequence_type] == SellerResponderSequence::SEQUENCE_SERIES[5]
         total_seller_profiles << seller_profile if  !seller_profile.seller_property_profile[0].responder_sequence_subscription or seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.seller_responder_sequence.sequence_name == params[:sequence_type]
       elsif seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.seller_responder_sequence.sequence_name == params[:sequence_type]
         next unless seller_profile.seller_property_profile[0].responder_sequence_subscription
         total_seller_profiles << seller_profile
       end
    end
     @seller_profiles = total_seller_profiles.paginate :page => params[:page], :per_page => 10
   end

  def get_seller_owner(seller_owners)
    unless seller_owners.blank?
      @seller_owner_one =  seller_owners[0].blank? ? nil : seller_owners[0]
      @seller_owner_two =  seller_owners[1].blank? ? nil : seller_owners[1]
      @seller_owner_three =  seller_owners[2].blank? ? nil : seller_owners[2]
      @seller_owner_four =  seller_owners[3].blank? ? nil : seller_owners[3]
    end
  end

  def create_or_update_seller_owner
    @seller_owners = @seller_property.seller_property_owners
    if @seller_owners.blank?
      if params[:seller_owner_one][:is_seller_lead_owner] == "true"
        seller_owner_one = create_seller_owner(@seller_profile.first_name.to_s)
      else
        seller_owner = create_seller_owner(params[:seller_owner_one][:owner_name])
        seller_owner = create_seller_owner(params[:seller_owner_two][:owner_name])
        seller_owner = create_seller_owner(params[:seller_owner_three][:owner_name])
        seller_owner = create_seller_owner(params[:seller_owner_four][:owner_name])
      end
    elsif params[:seller_owner_one][:is_seller_lead_owner] == "false"
      @seller_owner_one =  update_seller_owner_info(@seller_owners[0], params[:seller_owner_one][:owner_name])
      @seller_owner_two =  update_seller_owner_info(@seller_owners[1], params[:seller_owner_two][:owner_name])
      @seller_owner_three=  update_seller_owner_info(@seller_owners[2], params[:seller_owner_three][:owner_name])
      @seller_owner_four =  update_seller_owner_info(@seller_owners[3], params[:seller_owner_four][:owner_name])
    elsif params[:seller_owner_one][:is_seller_lead_owner] == "true"
      @seller_owner = update_seller_owner(@seller_owners[0], @seller_profile.first_name)
      @seller_owners[1].delete unless @seller_owners[1].blank?
      @seller_owners[2].delete unless @seller_owners[2].blank?
      @seller_owners[3].delete unless @seller_owners[3].blank?
    end
  end

  def update_seller_owner_info(seller_prop_owner, params_name)
    return seller_prop_owner.blank? ?  create_seller_owner(params_name) : update_seller_owner(seller_prop_owner, params_name)
  end

  def create_seller_owner(params_owner_name)
    return @seller_property.seller_property_owners.create(:is_seller_lead_owner => params[:seller_owner_one][:is_seller_lead_owner], :owner_name => params_owner_name) unless params_owner_name.blank?
  end

  def update_seller_owner(seller_owner, params_owner_name)
    return seller_owner.update_attributes(:is_seller_lead_owner => params[:seller_owner_one][:is_seller_lead_owner], :owner_name => params_owner_name) unless seller_owner.blank?
  end

  def assign_responder_seq_to_the_seller_profile
      seller_notification = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",current_user.id, SellerResponderSequence::SEQUENCE_SERIES[6]])
      seller_notification = SellerResponderSequence.create( :user_id => current_user.id, :sequence_name => SellerResponderSequence::SEQUENCE_SERIES[6], :active => true) if seller_notification.nil?
      seq_assign_to_seller = ResponderSequenceAssignToSellerProfile.create(:seller_property_profile_id => @seller_property.id, :seller_responder_sequence_id => seller_notification.id, :mail_number => 1)
#     end
    return seller_notification
  end

  def set_site_type
    @website_type = 'seller'
  end

  def is_seller_property_profile_exists
    begin
      @seller_property = @seller_profile.seller_property_profile[0]
      if @seller_property.blank?
        @seller_property = @seller_profile.seller_property_profile.build(params[:seller_property])
        @seller_property.property_type = "single_family"
        @seller_property.force_submit = true
        @seller_property.save!
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def get_seller_profile_and_seller_property_profile
    get_seller_and_seller_property_profile(params[:id])
  end
end
