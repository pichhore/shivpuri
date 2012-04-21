# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  layout "login_ui"
  # render new.rhtml
  def new
    if !params[:wp_request_uri].blank?
        session[:wp_url] = params[:wp_request_uri]
        redirect_to session[:wp_url] and return unless current_user == :false
    else
        session[:wp_url] = nil
    end
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if !self.current_user.is_user_have_access_to_reim and !self.current_user.admin_flag
      begin
        failed_user = self.current_user
        failed_user.update_attribute(:user_login_count_after_failed_payment,failed_user.user_login_count_after_failed_payment.to_i + 1 )
        
        if [1,2,3].include?(failed_user.user_login_count_after_failed_payment.to_i)
          UserTransactionHistory.create(:user_id => failed_user.id, :transanction_detail => "Failed payment login #{failed_user.user_login_count_after_failed_payment.to_i}")
        end
        
        if failed_user.user_login_count_after_failed_payment.to_i == 2
          Resque.enqueue(SendEmailToFailedUserWhenLoginSecondTimeWorker, current_user.id)
        elsif failed_user.user_login_count_after_failed_payment.to_i == 4
          user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:basic_type])
          failed_user.is_user_cancel_subscriptn_or_move_with_failed_pay = true
          failed_user.update_attributes(:user_class_id => user_class.id, :user_login_count_after_failed_payment => nil, :is_user_have_failed_payment=>false, :is_user_have_access_to_reim => true)
          
          UserTransactionHistory.create(:user_id => failed_user.id, :transanction_detail => "Customer with failed payment moved to Free level")
          flash[:notice] = "Welcome back!"
          return redirect_to :controller=>'account', :action=>'profiles'
        end
        return redirect_to :controller=> "sessions", :action => "shopping_cart_user_cancellation"
      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        logger.error("SessionsController") { "Error trying to update user's" }
      end
      end

      cookies[:user_id] = self.current_user.id
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      begin
        self.current_user.logged_in!
      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        logger.error("SessionsController") { "Error trying to update user's last_login_at field" }
      end

      #log_activity(:activity_category_id=>'cat_acct_login', :user_id=>self.current_user.id, :session_id=>session.session_id)
      log_activity(:activity_category_id=>'cat_acct_login', :user_id=>self.current_user.id, :session_id=>request.session_options[:id])
      flash[:notice] = "Welcome back!"

      if self.current_user.user_status == "Terms Accepted"
        redirect_to session[:wp_url] and return if session[:wp_url]
        testimonial_redirect = false
        if self.current_user.partner_account
          if request.env['HTTP_REFERER'].sub(REIMATCHER_URL,'') == self.current_user.partner_account.permalink
            testimonial_redirect = true
          end
        end
        if testimonial_redirect
          redirect_back_or_default(:controller=>'testimonials', :action=>'index')
        else
          redirect_back_or_default(:controller=>'account', :action=>'profiles')
        end
      else
        # self.current_user.user_status = "Completed"
        # self.current_user.save
        redirect_to session[:wp_url] and return if session[:wp_url]
        redirect_back_or_default(:controller=>'account', :action=>'welcome')
      end
    else
      flash.now[:error] = "Username or password not valid. Please try again.<br/> If you haven't activated your account, check your email box for an activation email."
      render :action => 'new'
    end
  end

  def destroy
    log_activity(:activity_category_id=>'cat_acct_logout', :user_id=>self.current_user.id, :session_id=>request.session_options[:id])
    cookies.delete :user_id
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been signed out"
    redirect_to new_session_url
  end

  def shopping_cart_user_cancellation
    render :file => "#{RAILS_ROOT}/public/404.html" and return if current_user == :false
    render :file => "#{RAILS_ROOT}/public/404.html" and return if current_user.blank?
  end

  def user_proceed_to_login
    cookies[:user_id] = self.current_user.id
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    begin
      self.current_user.logged_in!
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification( e,self, request, params)
      logger.error("SessionsController") { "Error trying to update user's last_login_at field" }
    end
    #log_activity(:activity_category_id=>'cat_acct_login', :user_id=>self.current_user.id, :session_id=>session.session_id)
    log_activity(:activity_category_id=>'cat_acct_login', :user_id=>self.current_user.id, :session_id=>request.session_options[:id])
    flash[:notice] = "Welcome back!"
    if self.current_user.user_status == "Terms Accepted"
      redirect_to session[:wp_url] and return if session[:wp_url]
      redirect_back_or_default(:controller=>'account', :action=>'profiles')
    else
      # self.current_user.user_status = "Completed"
      # self.current_user.save
      redirect_to session[:wp_url] and return if session[:wp_url]
      redirect_back_or_default(:controller=>'account', :action=>'welcome')
    end
  end
end
