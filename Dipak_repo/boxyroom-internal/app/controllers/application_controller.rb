# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :select_location

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :logged_in?, :id_params_required

  before_filter :set_current_user
  #before_filter :authenticate, :except => [:coming_soon]
  include ExceptionNotifiable

  protected

  def set_current_user
    Authorization.current_user = current_user
  end

  def render_optional_error_file(status_code)
    activate_authlogic
    status = interpret_status(status_code)
    render :template => "/errors/#{status[0,3]}.html.erb", :status => status, :layout => "full"
    #    if status_code == :not_found
    #      render :template => "/errors/404", :layout => "full"
    #    else
    #      render :template => "/errors/others", :layout => "full"
    #    end
  end

  def permission_denied
    flash[:error] = "Forbidden"
    redirect_to root_url and return
  end

  def authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == "boxyroom" && password == "staging"
      end
    end
  end

   def date_approve_hours_count(app)
      return (((Time.now).to_i - (app).to_i)/(3600) >= 48 )
   end

  def error_messages_in_sequence(errors, sequence)
    sequence_error = Array.new
    i = 0
    sequence.each do |att|
      errors.each do |err|
	if att == err[0]
	   err[1].each do |sub_err|
	     sequence_error[i] = sub_err
	     i = i+1
	   end
	end
      end
    end
    return sequence_error
  end

  def applications_for_my_properties
    properties = current_user.properties
    applications_for_me = Array.new
    i = 0
     properties.each do |f|
      temp = Application.find(:all, :conditions => ["property_id = ?", f.id])
      if temp.size>1
        temp.each do |t|
          applications_for_me[i] = t.to_a 
          i = i+1
        end
     elsif temp.size == 1 
        applications_for_me[i] = temp
        i = i+1
      end
     end
     return applications_for_me
  end
  
  def latest_applications_for_my_properties
    properties = current_user.properties
    applications_for_me = Array.new
    i = 0
     properties.each do |f|
      temp = Application.find(:all, :conditions => ["property_id = ? and (updated_at >= ? or status =?)", f.id, Time.now-(604800), "pending"])
      if temp.size>1
        temp.each do |t|
          applications_for_me[i] = t.to_a 
          i = i+1
        end
     elsif temp.size == 1 
        applications_for_me[i] = temp
        i = i+1
      end
     end
     return applications_for_me
  end

 private
 def select_location
   @location = FindLocationByIp.new(request.remote_ip) rescue nil
   Time.zone = @location.timezone unless @location.blank?
 end

  def id_params_required
    if params[:id].nil?
      flash[:error] = "You tried to perform an action without a variable"
      redirect_back_or_default("/")
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def logged_in?
    current_user
  end


  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_path
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to my_dashboard_my_account_path
      return false
    end
  end

  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if instance.error_message.kind_of?(Array)
      %(#{html_tag}).html_safe
    else
      %(#{html_tag}).html_safe
    end

end

end
