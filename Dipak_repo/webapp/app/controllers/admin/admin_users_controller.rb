require 'xmlrpc/client'

class Admin::AdminUsersController < Admin::AdminController
  active_scaffold :user do |config|
    list.columns = [:first_name, :last_name, :login, :created_at, :activated_at, :updated_at, :last_login_at, :admin_flag, :salt, :user_type_name]
    list.sorting = {:first_name => 'ASC'}
#     config.columns = [:first_name, :last_name, :login, :email, :activated_at, :admin_flag, :user_class_id,:number_of_territory]
#     columns[:activated_at].description = "Any non-empty value is considered activated"
#     config.columns[:user_class_id].form_ui = :select
#     config.columns[:user_class_id].options = {:options => UserClass.find(:all).collect!{|x| [x.user_type_name, x.id] }.insert(0, ["- Select -", ''])}
#     config.columns[:salt].label = "Password"
#     config.columns[:admin_flag].label = "Admin"
#     config.columns[:number_of_territory].label = "Territories"
    config.show.link.label = "<span onclick='javascript :  '>Access</span>"
    config.show.link.confirm="Once you click on Access button then You would be logged out from current user and login with this user"
    config.action_links.add 'show_badges', :label => "Assign Badge", :type => :record, :page => false
  end
  
  def change_password
    @user = User.find(params[:id])
    key = @user.generate_security_token
    redirect_to :controller=>"/account", :action=>"change_password", :id=>@user.id, :key=>key
  end

  def create
    if params[:record][:user_type] == "1"
        key = "649fd625fc4e786fc3edc0acae1bcd0d" #server
        #~ key="18a5c9c15885dd3bafcc6f58af5df2ea" #test
        server = XMLRPC::Client.new2("https://loveamerican.infusionsoft.com:443/api/xmlrpc") #server
        #~ server = XMLRPC::Client.new2("https://loveamerica.infusionsoft.com:443/api/xmlrpc")
        fields = ['FirstName', 'LastName', 'Email', 'Password', 'Phone1', 'StreetAddress1', 'City', 'State', 'PostalCode']
        table = "Contact"
        begin
          user = server.call("DataService.load", key, table, params[:record][:contactId].to_i, fields)
          pass = user['Password'].blank? ? "temp123" : user['Password']
          params[:user][:test_comp] = nil if params[:user][:test_comp] == ""
          @record =User.new(:login => user['Email'],:email=>user['Email'],:first_name=>user['FirstName'],:last_name=>user['LastName'],:password=>pass,:password_confirmation=>pass,:is_infusionsoft=>1, :user_class_id =>params[:record][:user_class_id], :activated_at=>params[:record][:activated_at],:number_of_territory=>params[:record][:number_of_territory],:add_user_comment=>params[:record][:add_user_comment],:complimentary_reason=>params[:user][:complimentary_reason],:test_comp=>params[:user][:test_comp], :admin_flag => params[:record][:admin_flag])
#           @record.activate if params[:record][:activated_at].blank?
          if @record.valid?
              @record.save
              render :text=>"<script type='text/javascript'>$('admin__admin_users-new--link').removeClassName('disabled'); $('admin__admin_users-search-container').innerHTML='<tr><td><div style=\"color:green;text-align:center;\" id=\"temp_show\">user account from InfusionSoft was created successfully</div></td></tr>'</script>"
          else
            @test_comp, @reason = @record.test_comp, @record.complimentary_reason

            render :action=>:new, :layout=>false
          end
        rescue Exception=>e
           ExceptionNotifier.deliver_exception_notification( e,self, request, params)
           render :text=>"<script type='text/javascript'>$('admin__admin_users-new--link').removeClassName('disabled'); $('admin__admin_users-search-container').innerHTML='<tr><td><div style=\"color:red;text-align:center;\" id=\"temp_show\">Record Not found in InfusionSoft</div></td></tr>'</script>"
        end
    else
        params[:user][:test_comp] = nil if params[:user][:test_comp] == ""
        @record = User.new(:login => params[:record][:email],:email=>params[:record][:email],:first_name=>params[:record][:first_name],:last_name=>params[:record][:last_name],:password=>params[:record][:password],:password_confirmation=>params[:record][:password_confirmation],:number_of_territory=>params[:record][:number_of_territory],:add_user_comment=>params[:record][:add_user_comment],:is_infusionsoft=>0, :user_class_id =>params[:record][:user_class_id], :activated_at=>params[:record][:activated_at],:complimentary_reason=>params[:user][:complimentary_reason],:test_comp=>params[:user][:test_comp], :admin_flag => params[:record][:admin_flag])
        if @record.valid?
          @record.save
          render :text=>"<script type='text/javascript'>$('admin__admin_users-new--link').removeClassName('disabled'); $('admin__admin_users-search-container').innerHTML='<tr><td><div style=\"color:green;text-align:center;\" id=\"temp_show\">user account was created successfully</div></td></tr>'</script>"
        else
          @test_comp, @reason = @record.test_comp, @record.complimentary_reason
          render :action=>:new, :layout=>false
        end
     end
  end

  def new
    @record = User.new
    render :layout=>false
  end

  def show
    @access_user=User.find(:first, :conditions=>["id=?","#{params[:id]}"])
    log_activity(:activity_category_id=>'cat_acct_logout', :user_id=>self.current_user.id, :session_id=>request.session_options[:id])
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete :user_id
    reset_session
    self.current_user = User.admin_access_user("#{@access_user.login}")
    if logged_in?
      cookies[:user_id] = self.current_user.id
      log_activity(:activity_category_id=>'cat_acct_login', :user_id=>self.current_user.id, :session_id=>request.session_options[:id])
      render :text => "<script type='text/javascript'>document.location.href='/account/profiles';</script>"
    end
  end

  def show_badges
    @badges = Badge.find(:all)
    @user_id = params[:id]
    @user_badges = BadgeUser.find_all_by_user_id(params[:id])
    render :layout=>false
  end
  
  def assign_badges
    @user_badges = BadgeUser.find_all_by_user_id(params[:user_id])
    badge_array = Array.new
    @user_badges.each do |user_badge|
      badge_array << user_badge.badge_id
      if !params[:user_badges].nil? && !params[:user_badges].has_key?(user_badge.badge_id.to_s)
        BadgeUser.destroy(user_badge.id)
      elsif params[:user_badges].nil?
        BadgeUser.destroy(user_badge.id)
      end
    end
    if !params[:user_badges].nil?
      params[:user_badges].each do |k, v|
        unless badge_array.include?(k.to_i)
          @user_badge = BadgeUser.new
          @user_badge.badge_id = k
          @user_badge.user_id = v
          @user_badge.save
          email_notification_to_user_for_badge(@user_badge)
        end
      end
    end
    render :text=>"<script type='text/javascript'>document.getElementsByClassName('show_badges-view view').hide();</script>"
    #redirect_to "/admin/admin_users"
  end

  def edit
    @user = User.find_by_id(params[:id])
    @user_pro_purchase = @user.map_lah_product_with_user
    @shopping_cart_user_details = @user.shopping_cart_user_detail
    @user_transaction_histories = @user.user_transaction_histories
    render :layout => false
  end

  def update
    unique_key = '1P1BgbKumGWJSI'
    @user = User.find_by_id(params[:id])
    @shopping_cart_user_details = @user.shopping_cart_user_detail
    @user_transaction_histories = @user.user_transaction_histories
    @user_pro_purchase = @user.map_lah_product_with_user
    params[:user][:test_comp] = nil if params[:user][:test_comp] == ""
    old_login_name = @user.login
    if @user.is_user_have_failed_payment and params["user"]["is_user_have_failed_payment"] == "0"
      params["user"]["is_user_have_access_to_reim"] = true
    elsif !@user.is_user_have_failed_payment and params["user"]["is_user_have_failed_payment"] == "1"
      params["user"]["is_user_have_access_to_reim"] = false
    end
    if @user.update_attributes(params[:user])
      if old_login_name != @user.login and RAILS_ENV == "production"
        UserForumIntegration.update_user_login_on_faq(old_login_name, @user.login, unique_key)
        UserForumIntegration.update_user_login_on_amps(old_login_name, @user.login, unique_key)
        UserForumIntegration.update_user_login_on_gold_coching(old_login_name, @user.login, unique_key)
      end
      if @user_pro_purchase.blank?
        user_map_pro = MapLahProductWithUser.new(params[:user_pro_purchase])
        user_map_pro.user_id = @user.id
        user_map_pro.save
      else
        @user_pro_purchase.update_attributes(params[:user_pro_purchase])
      end
      render :text=>'<script language="javascript">location.replace("/admin/admin_users");</script>'
    else
      render :action=>:edit, :layout=>false
    end
  end

  def email_notification_to_user_for_badge(badge_user)
   user_email = badge_user.user.email
   name = badge_user.user.first_name
   badge = badge_user.badge
   image = badge_user.badge.badge_image
  # Resque.enqueue(SendNotificationForNewBadgeWorker,user_email, name, badge.name, image, badge.email_subject, badge.email_body, badge.email_header, badge.email_footer)
   UserNotifier.deliver_send_notification_for_new_badge(user_email, name, badge.name, image, badge.email_subject, badge.email_body, badge.email_header, badge.email_footer)
  end
 
end

