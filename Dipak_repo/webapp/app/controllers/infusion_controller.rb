require 'xmlrpc/client'
class InfusionController < ApplicationController
  skip_before_filter :verify_authenticity_token
  PROD_NAME = "product-maps"
  def index
    begin
      # Write the code that will log all the params in a special log file  so that we know the params that infusion soft sends . Return after that as we dont need any processing to be done at the moment .
      infusion_logfile = File.open("#{RAILS_ROOT}/log/infusion_params.log", 'a')
      infusion_logfile.sync = true
      infusion_logger = InfusionLogger.new(infusion_logfile)
      infusion_logger.debug params.to_yaml

      key = "649fd625fc4e786fc3edc0acae1bcd0d" #server
      #~ key="18a5c9c15885dd3bafcc6f58af5df2ea" #test
      server = XMLRPC::Client.new2("https://loveamerican.infusionsoft.com:443/api/xmlrpc")
      fields = ['FirstName', 'LastName', 'Email', 'Password', 'Phone1', 'StreetAddress1', 'City', 'State', 'PostalCode']
      table = "Contact"
      #     begin
      user = server.call("DataService.load", key, table, params[:Id].to_i, fields)
      pass = user['Password'].blank? ? "test123" : user['Password']
      reim_user = User.find(:first, :conditions => ["email = ? OR login = ?", user['Email'], user['Email']])
      render :text => "#{infusion_logger.info "User have account in REIM: #{user['Email']}"}" and return unless reim_user.blank?
      if params[:prodname] == PROD_NAME
      user_class = UserClass.find(:all,:conditions=>["user_type = ?" , "UC1"])
              if user_class.size == 1
                @user_class_id = user_class[0].id
              end
      end
      infusion_user =User.create(:login => user['Email'],:email=>user['Email'],:first_name=>user['FirstName'],:last_name=>user['LastName'],:password=>pass,:password_confirmation=>pass,:is_infusionsoft=>1, :user_class_id =>@user_class_id)
      infusion_user.activate
      cookies.delete :auth_token
      reset_session
      log_activity(:activity_category_id=>'cat_acct_activated', :user_id=>infusion_user.id, :session_id=>request.session_options[:id])
      companyinfo =UserCompanyInfo.new
      companyinfo.user_id=infusion_user.id
      companyinfo.business_address=user['StreetAddress1']
      companyinfo.business_name='Business Name'
      companyinfo.business_phone=user['Phone1']
      companyinfo.business_email=user['Email']
      companyinfo.city=user['City']
      companyinfo.state=user['State']
      companyinfo.zipcode=user['PostalCode']
      companyinfo.save(false)
      get_params = request.url.split("?") unless request.url.nil?
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
      render :text => "OK"
  end
end
