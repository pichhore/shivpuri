class UsersController < ApplicationController
  before_filter :secrete_key_required, :only=>["update_password_from_forum","show"]

  # render new.rhtml
  def new
    render :file => "#{RAILS_ROOT}/public/404.html"
  end

  def thanks
    @user = User.find_by_email(params[:email])
  end

  def pro_offer
    @user = flash[:user]
    render :layout => false
  end

  def prothanks
    render :layout => false
  end

  def show
    @user = User.find(:first, :conditions => ["id=?", params[:id]])
    return render :json => { :user_not_found => "user not found with the id #{params[:id]}" } if @user.blank?
    image_path = !@user.buyer_user_image.blank? ? ( !@user.buyer_user_image.find_profile_thumbnail.blank? ? @user.buyer_user_image.public_filename(:profile) : nil) : nil
    image_path = REIMATCHER_URL.chop + image_path if !image_path.blank?
    user_class = @user.user_class.blank? ? nil : @user.user_class.user_type
    lah_product = @user.map_lah_product_with_user
    product_purchased = Array.new
    unless lah_product.blank?
      product_purchased << "amps" if lah_product.amps
      product_purchased << "gold_amps" if lah_product.amps_gold
      product_purchased << "top1" if lah_product.top1
      product_purchased << "re_volution" if lah_product.re_volution
      product_purchased << "LAH" if lah_product.rei_mkt_dept
      product_purchased << "wholesaling" if lah_product.wholesaling
      product_purchased << "blueprint" if lah_product.blueprint
      product_purchased << "allinone" if lah_product.allinone
    end
    render :json => {:user=>{
				:login=>@user.login,
				:first_name=>@user.first_name,
                        	:last_name=>@user.last_name,
                        	:email =>@user.email,
				:is_admin=>@user.admin_flag,
                                :user_profile_image_path=>image_path,
                                :user_subscription_level => user_class,
                                :product_purchased => product_purchased
                             }
		    }
  end

  def buyer_created
    @user = flash[:user]
    flash.now[:type] = "buyer"
    render :action=>"thanks"
  end

  def owner_created
    @user = flash[:user]
    flash.now[:type] = "owner"
    render :action=>"thanks"
  end

  def buyer_agent_created
    @user = flash[:user]
    flash.now[:type] = "buyer_agent"
    render :action=>"thanks"
  end

  def seller_agent_created
    @user = flash[:user]
    flash.now[:type] = "seller_agent"
    render :action=>"thanks"
  end
  
  def create    
    begin
      password = random_password_string
      @user = User.new(params[:user].merge({:password => password,
                                            :password_confirmation => password, 
                                            :skip_last_name => true,
                                            :is_user_comes_from_reim_home_page => true,
                                            :login => params[:user][:email],
                                            :user_class_id => UserClass.free_user }))
      if @user.save
        flash[:user] = @user
        redirect_to :action => 'pro_offer'
      else
        flash[:user] = @user
        redirect_to :controller => 'home', :action => 'index'
      end
    rescue ActiveRecord::RecordInvalid => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      render :action => 'new'
    end
  end
  
  def activate
    # TODO: add test to verify this doesn't login to the first user with a nil activation code
    # http://www.rorsecurity.info/2007/10/28/restful_authentication-login-security/
    user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if user.blank?
      render :file => "#{RAILS_ROOT}/public/404.html"
      return false
    end
    if user && !user.activated?
      user.activate
      self.current_user = user
      log_activity(:activity_category_id=>'cat_acct_activated', :user_id=>user.id, :session_id=>request.session_options[:id])
      flash[:notice] = "Activation complete. Welcome!"
    end
    profile = Profile.find(params[:profile_id]) if ! params[:profile_id].blank?
    if profile.nil?
      if current_user.user_status == 'Terms Accepted'
        redirect_back_or_default(:controller=>'account', :action=>'profiles')
      else
        redirect_back_or_default(:controller=>'account', :action=>'welcome')
      end
    else
     #redirect_to profile_profile_images_url(profile)+'?new=true'
      redirect_to profile_profile_images_path(profile, :new=>"true")
    end
  end

  def user_activate
    @user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if @user.blank?
      handle_error("This link has been used/clicked- please go to <a href='#{REIMATCHER_URL}login'>#{REIMATCHER_URL}login </a> to log in") and return
    end
    render :layout => "login_ui"
  end

  def update_activation
    begin
      # TODO: add test to verify this doesn't login to the first user with a nil activation code
      # http://www.rorsecurity.info/2007/10/28/restful_authentication-login-security/
      @user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
      if @user && !@user.activated?
        if params['user']['password'] and !params['user']['password'].empty?
          if (params['user']['password'] == params['user']['password_confirmation'])
            @user.change_password(params['user']['password'], params['user']['password_confirmation'])
            @user.activated_at = Time.now.utc
            @user.activation_code = nil
            @user.save!
            self.current_user = @user
            cookies[:user_id] = self.current_user.id
            log_activity(:activity_category_id=>'cat_acct_activated', :user_id=>@user.id, :session_id=>request.session_options[:id])
            flash[:notice] = "Activation complete. Welcome!"
            redirect_back_or_default(:controller=>'account', :action=>'welcome')
            return
          else
            flash[:error] = "Password and password confirmation do not match"
            redirect_to :action => :user_activate, :activation_code => params[:activation_code],  :layout => "login_ui"
            return
          end
        else
          flash[:error] = "Password can't be nil"
          redirect_to :action => :user_activate,:activation_code => params[:activation_code], :layout => "login_ui"
          return
        end
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    end
    render :file => "#{RAILS_ROOT}/public/404.html" and return
  end

   def spam_reason
        render :partial=>"spam_sent" do |page|
          # add the new tag to the top of the table
          page.replace_html "marked_as_spam_#{the_dom_id}", "Marked as spam"
          # highlight the new text
          page.visual_effect :highlight, "marked_as_spam_#{the_dom_id}"
        end if request.xhr?
   end

  def give_spam_reason
     @investor_messages = InvestorMessage.find(params[:message_id])
      the_dom_id = params[:message_id] if params[:message_id]
      spam_claim = SpamClaim.new({ :claim_type=>'InvestorMessage', :claim_id=>current_user.id, :created_by_user_id=>params[:id]})
      begin
        spam_claim.save!
        spam_claim.connection.update("UPDATE investor_messages SET marked_as_spam = true, spam_reason = '#{params[:investor_message][:spam_reason]}' WHERE id = '#{params[:message_id]}'")

        #sending email through Resque
        Resque.enqueue(InvestorMessageMarkedAsSpamNotificationWorker,spam_claim.id, params[:message_id])

        render :text=>"Marked as spam"

      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e, self, request, params)
        handle_error("Internal error - could not mark as spam",e) and return
      end
  end

  def mark_as_spam
     render :layout=>false
  end

  def update_password_from_forum
    logger=Logger.new("#{RAILS_ROOT}/log/password_change_from_forum.log")
    logger.debug params.to_yaml
    if request.post?
      begin
        @user = User.find_by_login(params[:login])
        unless @user.blank?
          @user.change_password_for_forum(params['password'], params['password_confirmation'])
          if @user.save
            Resque.enqueue(ChangePasswordNotificationWorker, @user.id, params['password'] )
            logger.info "success"
            render :json => {"00s" => "success"} and return
          else
            logger.info "New password and confirm password should be same"
            render :json => {"008" => "New password and confirm password should be same"} and return
          end
        else
          logger.info "User doesn't exist"
          render :json => {"004" => "User doesn't exist"} and return
        end

        rescue  Exception => exp
            ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
            handle_error("Error trying to change password. Please try again later or contact support",exp) and return
        end
      else
          logger.info "HTTP method not supported"
          render :json => {"001" => "HTTP method not supported"} and return
      end
  end

end
