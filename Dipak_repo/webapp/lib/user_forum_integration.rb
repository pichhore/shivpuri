class UserForumIntegration
  
require "net/http"
require "uri"
  
# url for user forum integration
  URL_FOR_CREATE_USER_AT_FORUM = "http://www.reimatcher.com/forum/forumApi/create_user/"
  URL_FOR_CHANGE_PASSWORD_AT_FORUM = "http://www.reimatcher.com/forum/forumApi/change_password/"
  URL_FOR_UPDATE_PROFILE_PICTURE_AT_FORUM = "http://www.reimatcher.com/forum/forumApi/update_profile_pic/"
  URL_FOR_UPDATE_PROFILE_PICTURE_AT_FAQ = "http://www.reimatcher.com/faq/wp_update_profile_pic.php"
  URL_FOR_UPDATE_PROFILE_PICTURE_AT_GOLDCOACHING = "http://www.reimatcher.com/training/goldcoaching/goldcoaching_update_profile_pic.php"
  URL_FOR_UPDATE_PROFILE_PICTURE_AT_AMPS = "http://www.reimatcher.com/training/amps/amps_update_profile_pic.php"
  
  
# url for wordpress integration
  URL_FOR_UPDATE_USER_LOGIN_AT_FAQ = "http://www.reimatcher.com/faq/reim_change_username.php"
  URL_FOR_UPDATE_USER_LOGIN_AT_AMPS = "http://www.reimatcher.com/training/amps/reim_change_username.php"
  URL_FOR_UPDATE_USER_LOGIN_AT_GOLDCOCHING = "http://www.reimatcher.com/training/goldcoaching/reim_change_username.php"
  ALLINONE_WORDPRESS_URL = "http://www.reimatcher.com/training/allinone/wp-content/plugins/wishlist-member-customizations"
  MRMM_WORDPRESS_URL = "http://www.reimatcher.com/training/myreimarketingmachine/wp-content/plugins/wishlist-member-customizations"
  
  def self.update_profile_picture_on_other_products(login, image_path)
    UserForumIntegration.update_profile_picture_on_forum(login, image_path)
    UserForumIntegration.update_profile_picture_on_faq(login, image_path)
    UserForumIntegration.update_profile_picture_on_amps(login, image_path)
    UserForumIntegration.update_profile_picture_on_goldcoaching(login, image_path)
  end

  def self.create_user_and_assign_membersip_at_wordpress_instance(user_login, user_email, product_name)
    self.create_user_on_re_volution2_wp_incetance(user_login, user_email) if product_name=="allinone"
    self.create_user_on_mrmm_wp_instance(user_login, user_email) if product_name=="mrmm"
  end

  def self.remove_membersip_for_user_from_wordpress_instance(user_login, user_email, product_name)
    self.remove_membership_from_allinone_wp_instance(user_login, user_email) if product_name=="allinone"
    self.remove_membership_from_mrmm_wp_instance(user_login, user_email) if product_name=="mrmm"
  end

  def self.create_user_on_forum(username, password, email)
    logger=Logger.new("#{RAILS_ROOT}/log/user_forum_integration.log")
    uri = URI.parse(URL_FOR_CREATE_USER_AT_FORUM)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "username=#{username}&password=#{password}&email=#{email}"
    response = http.request(request)
    response.body
  
    if JSON.parse(response.body)["error_no"] == "007"
      logger.info " User alreay exist :  #{username} "
    elsif JSON.parse(response.body)["error_no"] == "005"
      logger.info " Email is not valid :  #{username} "
    elsif JSON.parse(response.body)["error_no"] == "00s"
      logger.info " User Successfully registered :  #{username} "
    end
  end
   
  def self.create_user_on_re_volution2_wp_incetance(user_name, user_email)
    begin
      uri = URI.parse("#{ALLINONE_WORDPRESS_URL}/adduser.php?user_name=#{user_name}&user_email=#{user_email}")
      response = self.method_for_http_get_request(uri)
  
      if JSON.parse(response)["error"]==0
        uri = URI.parse("#{ALLINONE_WORDPRESS_URL}/addmember.php?user=#{JSON.parse(response)["user_id"]}&level=1329849613")
        return self.method_for_http_get_request(uri)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"WordPress")
    end
  end

  def self.remove_membership_from_allinone_wp_instance(user_name, user_email)
    begin
      uri = URI.parse("#{ALLINONE_WORDPRESS_URL}/adduser.php?user_name=#{user_name}&user_email=#{user_email}")
      response = self.method_for_http_get_request(uri)

      if JSON.parse(response)["error"]==0 or JSON.parse(response)["error"]==1
        uri = URI.parse("#{ALLINONE_WORDPRESS_URL}/removemember.php?user=#{JSON.parse(response)["user_id"]}&level=1329849613")
        return self.method_for_http_get_request(uri)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"WordPress")
    end
  end

  def self.create_user_on_mrmm_wp_instance(user_name, user_email)
    begin
      uri = URI.parse("#{MRMM_WORDPRESS_URL}/adduser.php?user_name=#{user_name}&user_email=#{user_email}")
      response = self.method_for_http_get_request(uri)

      if JSON.parse(response)["error"]==0 or JSON.parse(response)["error"]==1
        uri = URI.parse("#{MRMM_WORDPRESS_URL}/addmember.php?user=#{JSON.parse(response)["user_id"]}&level=1330980034")
        return self.method_for_http_get_request(uri)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"WordPress")
    end
  end

  def self.remove_membership_from_mrmm_wp_instance(user_name, user_email)
    begin
      uri = URI.parse("#{MRMM_WORDPRESS_URL}/adduser.php?user_name=#{user_name}&user_email=#{user_email}")
      response = self.method_for_http_get_request(uri)

      if JSON.parse(response)["error"]==0  or JSON.parse(response)["error"]==1
        uri = URI.parse("#{MRMM_WORDPRESS_URL}/removemember.php?user=#{JSON.parse(response)["user_id"]}&level=1330980034")
        return self.method_for_http_get_request(uri)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"WordPress")
    end
  end

  def self.change_password_on_forum(username, new_password, password_confirm)
    logger=Logger.new("#{RAILS_ROOT}/log/user_forum_integration.log")
    uri = URI.parse(URL_FOR_CHANGE_PASSWORD_AT_FORUM)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "username=#{username}&new_password=#{new_password}&password_confirm=#{password_confirm}"
    response = http.request(request)
    response.body
  
    if JSON.parse(response.body.gsub('1',''))["error_no"] == "00s"
      logger.info " Password Update Successfully :  #{username} "
    elsif JSON.parse(response.body)["error_no"] == "008"
      logger.info " New password and confirm password should be same :  #{username} "
    elsif JSON.parse(response.body)["error_no"] == "004"
      logger.info " User doesn't exist :  #{username} "
    end
  end
  
  def self.update_profile_picture_on_forum(username, fileupload)
    logger=Logger.new("#{RAILS_ROOT}/log/user_forum_integration.log")
    uri = URI.parse(URL_FOR_UPDATE_PROFILE_PICTURE_AT_FORUM)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "username=#{username}&fileupload=#{fileupload.to_s}"
    response = http.request(request)
    response.body
  
    logger.info " Profile image uploaded and has been saved in forum db successfully :  #{username} "
  end
  
  def self.update_profile_picture_on_faq(username, fileupload)
    logger=Logger.new("#{RAILS_ROOT}/log/user_faq_integration.log")
    uri = URI.parse(URL_FOR_UPDATE_PROFILE_PICTURE_AT_FAQ)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "username=#{username}&fileupload=#{fileupload.to_s}"
    response = http.request(request)
    response.body
  
    logger.info " Profile image uploaded and has been saved in faq db successfully :  #{username} "
  end
  
  def self.update_profile_picture_on_amps(username, fileupload)
    logger=Logger.new("#{RAILS_ROOT}/log/user_amps_integration.log")
    uri = URI.parse(URL_FOR_UPDATE_PROFILE_PICTURE_AT_AMPS)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "username=#{username}&fileupload=#{fileupload.to_s}"
    response = http.request(request)
    response.body
  
    logger.info " Profile image uploaded and has been saved in amps db successfully :  #{username} "
  end
  
  def self.update_profile_picture_on_goldcoaching(username, fileupload)
    logger=Logger.new("#{RAILS_ROOT}/log/user_goldcoaching_integration.log")
    uri = URI.parse(URL_FOR_UPDATE_PROFILE_PICTURE_AT_GOLDCOACHING)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "username=#{username}&fileupload=#{fileupload.to_s}"
    response = http.request(request)
    response.body
  
    logger.info " Profile image uploaded and has been saved in goldcoaching db successfully :  #{username} "
  end
  
  def self.update_user_login_on_faq(old_username, new_username, unique_key)
    logger=Logger.new("#{RAILS_ROOT}/log/update_user_login_on_wordpress.log")
    uri = URI.parse(URL_FOR_UPDATE_USER_LOGIN_AT_FAQ)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "old_username=#{old_username}&new_username=#{new_username}&unique_key=1P1BgbKumGWJSI"
    response = http.request(request)
    response.body
  
    logger.info " Login Updated Successfully :  Old User Name=> #{old_username} and New User Name=> #{new_username} "
  end
  
  def self.update_user_login_on_amps(old_username, new_username, unique_key)
    logger=Logger.new("#{RAILS_ROOT}/log/update_user_login_on_wordpress.log")
    uri = URI.parse(URL_FOR_UPDATE_USER_LOGIN_AT_AMPS)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "old_username=#{old_username}&new_username=#{new_username}&unique_key=1P1BgbKumGWJSI"
    response = http.request(request)
    response.body
  
    logger.info " Login Updated Successfully :  Old User Name=> #{old_username} and New User Name=> #{new_username} "
  end
  
  def self.update_user_login_on_gold_coching(old_username, new_username, unique_key)
    logger=Logger.new("#{RAILS_ROOT}/log/update_user_login_on_wordpress.log")
    uri = URI.parse(URL_FOR_UPDATE_USER_LOGIN_AT_GOLDCOCHING)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= "old_username=#{old_username}&new_username=#{new_username}&unique_key=1P1BgbKumGWJSI"
    response = http.request(request)
    response.body
  
    logger.info " Login Updated Successfully :  Old User Name=> #{old_username} and New User Name=> #{new_username} "
  end
  
private
  
  def self.method_for_http_get_request(uri)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      return response.body
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"WordPress")
    end
  end
end