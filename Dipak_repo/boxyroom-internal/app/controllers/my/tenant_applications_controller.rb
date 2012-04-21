class My::TenantApplicationsController < ApplicationController
  before_filter :require_user
  
  before_filter :check_rental_property, :only =>[  :write_review,:create_review ]
  before_filter :check_application_status, :only =>[  :make_payment ]
  before_filter :check_payment_status_after_payment, :only => [:payment_notification_detail]
  filter_access_to :all
  
  SEQUENCE_OF_VALIDATION_MESSAGES = ['expected_arrival', 'duration_of_stay', 'card_first_name', 'card_last_name', 'card_email', 'card_phone_no', 'card_mobile_no','card_fax_no', 'profile_income_source', 'profile_student_no', 'profile_weekly_income','weekly_income','profile_start_of_employment','start_of_employment','profile_company_name','company_name' , 'profile_industry','industry', 'profile_position','position','profile_gross_annual_salary', 'profile_guardian_first_name', 'profile_guardian_last_name',  'profile_guardian_email' ,'profile_guardian_phone_no', 'profile_guardian_mobile_no', 'profile_guardian_fax_no',  'profile_superior_first_name', 'profile_superior_last_name', 'profile_superior_email', 'profile_superior_phone_no', 'profile_superior_mobile_no', 'profile_superior_fax_no', 'profile_previous_destination','previous_destination' , 'profile_next_destination', 'profile_reason_for_moving','reason_for_moving']
  
    ERROR_SEQUENCE_HASH = { :profile_guardian_first_name => {"First name must be more than 1 character." => "Guardian's first name must be more than 1 character." ,  "Enter your first name." => "Enter Guardian's first name.", "Your first name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." => "Guardian's first name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." }, :profile_guardian_last_name => { "Last name must be more than 1 character ." => "Guardian's last name must be more than 1 character.", "Enter your last name." => "Enter Guardian's last name.",  "Your last name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." => "Guardian's last name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." }, :profile_guardian_email =>{ "Email must be more than 1 character ." => "Guardian's email must be more than 1 character." , "Email address doesn't look correct." => "Guardian's email doesn't look correct."} , :profile_guardian_phone_no => {"Phone no must be more than 5 digits." => "Guardian's phone no must be more than 5 digits." }, :profile_guardian_mobile_no =>{"Mobile no must be more than 5 digits."  => "Guardian's mobile no must be more than 5 digits."}, :profile_guardian_fax_no => { "Fax no must be more than 5 digits." => "Guardian's fax no must be more than 5 digits." }, :profile_superior_first_name => { "First name must be more than 1 character." => "Superior's first name must be more than 1 character.", "Enter your first name." => "Enter Superior's first name.",  "Your first name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." => "Superior's first name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." }, :profile_superior_last_name => {"Last name must be more than 1 character ." => "Superior's last name must be more than 1 character.", "Enter your last name."=> "Enter Superior's last name.", "Your last name must have characters [ 0-9, a-z, A-Z,  -,  _ ]." => "Superior's last name must have characters [ 0-9, a-z, A-Z,  -,  _ ]."}, :profile_superior_email =>{"Email must be more than 1 character ." => "Superior's email must be more than 1 character.", "Email address doesn't look correct." => "Superior's email doesn't look correct." }, :profile_superior_phone_no => {"Phone no must be more than 5 digits." =>"Superior's phone no must be more than 5 digits."},  :profile_superior_mobile_no =>{ "Mobile no must be more than 5 digits." => "Superior's mobile no must be more than 5 digits."} , :profile_superior_fax_no => { "Fax no must be more than 5 digits." => "Superior's fax no must be more than 5 digits." } }
    
    
  def index
    @applications = current_user.applications
  end

  def show
    @application = current_user.applications.find(params[:id])

    #TODO why is this here?
    @application.first_name ||= current_user.first_name
    @application.last_name ||= current_user.last_name
    @selected_tab = "Applications"
     render :layout=>"new/application"
  end

  def make_payment
    #TODO why is this here?
    @application.first_name ||= current_user.first_name
    @application.last_name ||= current_user.last_name
    @selected_tab = "Properties"
     render :layout=>"new/application"
  end
  
  def edit
    @application = current_user.applications.find(params[:id])
    @application.profile.superior ||= Card.new
    @application.profile.guardian ||= Card.new
    render :layout=>"new/application" 
  end

  def update
    @application = current_user.applications.find(params[:id])
    profile_attributes = params[:application].delete(:profile_attributes)
    case profile_attributes[:value_type].tableize.singularize.gsub("_", "-")
    when "study-profile"
      superior_attributes = profile_attributes.delete(:superior_attributes)
      profile = StudyProfile.new(profile_attributes)
      profile.superior = nil
      if @application.profile.nil?
            @application.profile  = profile
     else
          @application.profile.attributes = profile_attributes
          @application.profile.superior = nil unless  @application.profile.superior.nil?
     end
    when "business-profile"
      guardian_attributes = profile_attributes.delete(:guardian_attributes)
      profile = BusinessProfile.new(profile_attributes)
      profile.guardian = nil
      if @application.profile.nil?
            @application.profile  = profile
     else
          @application.profile.attributes = profile_attributes
          @application.profile.guardian = nil unless  @application.profile.guardian.nil?
     end
    when "travel-profile"
      superior_attributes = profile_attributes.delete(:superior_attributes)
      guardian_attributes = profile_attributes.delete(:guardian_attributes)
      profile = TravelProfile.new(profile_attributes)
      if @application.profile.nil?
            @application.profile  = profile
     else
          @application.profile.attributes = profile_attributes
          @application.profile.guardian = nil unless  @application.profile.guardian.nil?
	      @application.profile.superior = nil unless  @application.profile.superior.nil?
     end
    end
    @application.attributes = params[:application]
    if @application.valid? and profile.valid?
      @application.save
      resend_app
      redirect_to my_applications_my_applications_path and return
    else
      @application.profile.type_changed? ? error_messages_in_sequence_for_edit_profile_type(profile) : error_messages_in_sequence
      flash[:error] = "You cannot apply for this listing."
      @application.profile.superior ||= Card.new(superior_attributes)
      @application.profile.guardian ||= Card.new(guardian_attributes)
      render :edit,:layout=>"new/application"
    end
  end

  def new
    property = Property.find(params[:property_id])
    # can this be moved to declarative authorization?
    if property.owner == current_user
      flash[:error] = "You can't apply for your own property"
      redirect_to my_dashboard_my_account_path and return
    end
    if current_user.applications.exists?(:property_id => params[:property_id])
      flash[:error] = "You've already applied for this property"
      redirect_to home_path and return
    end
      @application = property.applications.new
      @application.build_profile
      @application.build_card
      @application.build_landlord
      @application.profile.type = "Study-Profile"
      @application.profile.superior = Card.new
      @application.profile.guardian = Card.new

      @application.card.first_name ||= current_user.first_name
      @application.card.last_name ||= current_user.last_name
      @application.card.email ||= current_user.email
     render :layout=>"new/application" 
  end

  def create
    @property = Property.find(params[:property_id])
    profile_attributes = params[:application].delete(:profile_attributes)
    case profile_attributes[:value_type].tableize.singularize.gsub("_", "-")
    when "study-profile"
      superior_attributes = profile_attributes.delete(:superior)
      profile = StudyProfile.new(profile_attributes)
      profile.superior = nil
    when "business-profile"
      guardian_attributes = profile_attributes.delete(:guardian)
      profile = BusinessProfile.new(profile_attributes)
      profile.guardian = nil
    when "travel-profile"
      superior_attributes = profile_attributes.delete(:superior)
      guardian_attributes = profile_attributes.delete(:guardian)
      profile = TravelProfile.new(profile_attributes)
      profile.superior = nil
      profile.guardian = nil
    end
    @application = @property.applications.new(params[:application])
    @application.profile = profile
    @application.user = current_user
    if  @application.save
      flash[:notice] = "Your application has been submitted."
      redirect_to my_dashboard_my_account_path and return
    else
      @application.profile.superior ||= Card.new(superior_attributes)
      @application.profile.guardian ||= Card.new(guardian_attributes)
      error_messages_in_sequence
      flash[:error] = "You cannot apply for this listing."
      render :new,:layout=>"new/application"
    end
  end

  def destroy
    @application = current_user.applications.find(params[:id])

    if @application.cancel!
      flash[:notice] = "You've cancelled an application."
    else
      flash[:notice] = "You cannot cancel this application."
    end

    redirect_to my_dashboard_my_account_path
  end

  def resend
    @application = current_user.applications.find(params[:id])

    if @application.resend!
      flash[:notice] = "You've resent this application."
    else
      flash[:notice] = "You cannot resend this application."
    end

    redirect_to my_dashboard_my_account_path
  end

  def pay
    @application = current_user.applications.find(params[:id])

    @application.build_billing_address(params[:application].delete(:billing_address)) if @application.billing_address.nil?

    @application.attributes = params[:application]
    @application.ip_address = request.remote_ip

    @application.validate_card # make this automatically whenever a payment is being made

    if @application.valid? && @application.make_payment!
      redirect_to my_application_path(@application)
    else
      render :show
    end
  end

  def write_review
    @review = Review.new
    @review.rental_from = @application.expected_arrival
    @review.rental_to  = (@review.rental_from + @application.duration_of_stay.months)
    @review.profile_type = "study-profile"
    3.times { @review.reivew_property_pictures.build }
    render :layout=>"new/application"
  end

  def create_review
    @review = Review.new(params[:review])
    @review.application_id = @application.id
    @review.property_id = @application.property_id
    if @review.save
      flash[:notice] = "You've given review for this application successfully!"
      redirect_to my_dashboard_my_account_path
   else
      3.times { @review.reivew_property_pictures.build }
      render :write_review,:layout=>"new/application"
    end
  end

   def payment_notification_detail
      @user = @current_user
      properties = Property.find(:all, :conditions => ["user_id = ? and status=?", @current_user.id, 'occupied'])
      @applications_for_me = Array.new
      @applications_for_me = applications_for_my_properties
       render :layout=>"new/application"
   end


  def my_applications
    @user = @current_user #User.find(params[:id])
    @applications = @user.applications.paginate :page => params[:page],:per_page =>50
#   @applications = application.paginate :page => params[:page], :order => 'created_at DESC'
    @selected_tab = "Applications"
    render :layout=>"new/application"
  end

  private

  def check_rental_property
    @application = current_user.applications.find(params[:id])
    unless can_write_review(@application)
      flash[:notice] = "You are not allowed to write review for the property."
      redirect_to my_applications_my_applications_path and return
    end
  end

  def check_application_status
    @application = current_user.applications.find(params[:id])
    unless !@application.paid?
      flash[:notice] = "Payment has been made."
      redirect_to my_dashboard_my_account_path and return
    end
  end

  def check_payment_status_after_payment
    @application = Application.find(params[:id])
    unless @application.paid?
      flash[:notice] = "You must pay for the request to fulfil."
      redirect_to my_dashboard_my_account_path and return
    end
  end

  def can_write_review(application)
     if application.moved_in? and application.review.nil? and (application.expected_arrival <= Date.today) and !application.paid_at.nil?
        if ((Date.today - 2)>  (application.paid_at.time).to_date)
           return true
	else
	   return false
	end
    else
        return false
     end
  end

  def error_messages_in_sequence
    sequence_error = Array.new
    SEQUENCE_OF_VALIDATION_MESSAGES.each do |err_key|
      unless @application.errors[err_key.to_sym].nil?
        if ERROR_SEQUENCE_HASH[err_key.to_sym].nil?
	 @application.errors[err_key.to_sym].each do |errors|
           sequence_error << errors
	 end
	else
	 @application.errors[err_key.to_sym].each do |errors|
            sequence_error << ERROR_SEQUENCE_HASH[err_key.to_sym][errors]
	  end
	end
      end
    end
    @application.errors.clear
    sequence_error.each do |mess|
      @application.errors.add_to_base(mess)
    end     
  end

  def error_messages_in_sequence_for_edit_profile_type(profile)
    profile.valid?
    sequence_error = Array.new
    SEQUENCE_OF_VALIDATION_MESSAGES.each do |err_key|
      unless @application.errors[err_key.to_sym].nil?
        if ERROR_SEQUENCE_HASH[err_key.to_sym].nil?
	 @application.errors[err_key.to_sym].each do |errors|
           sequence_error << errors
	 end
	else
	 @application.errors[err_key.to_sym].each do |errors|
            sequence_error << ERROR_SEQUENCE_HASH[err_key.to_sym][errors]
	  end
	end
      end
      unless profile.errors[err_key.to_sym].nil?
        profile.errors[err_key.to_sym].each do |errors|
           sequence_error << errors unless sequence_error.include?(errors)
	 end
      end
    end
    @application.errors.clear
    sequence_error.each do |mess|
      @application.errors.add_to_base(mess)
    end     
  end
 
  def resend_app
    @n_application = current_user.applications.find(@application.id)
    if @n_application.resend!
      flash[:notice] = "You've resent this application."
    else
      flash[:notice] = "You cannot resend this application."
    end 
  end 

end
