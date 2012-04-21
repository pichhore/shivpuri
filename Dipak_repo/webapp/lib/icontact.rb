require 'net/http'

class Icontact

  ICONTACT_URL = "https://app.icontact.com/icp/a/#{ICONTACT_HTTP_HEADER[:accountid]}/c/#{ICONTACT_HTTP_HEADER[:clientfolderid]}"

  DEFAULT_PASS_FOR_FREE_CLASS = "4reimatcher"
  BATCH_SIZE = 10

  def initialize(header_content)
     @headers = {
          'Accept' => header_content[:accept_type],
          'Content-Type' => header_content[:content_type],
          'Api-Version' => header_content[:api_version],
          'Api-AppId' => header_content[:api_app_id],
          'Api-Username' => header_content[:api_user_name],
          'API-Password' => header_content[:api_password]
      }
  end

  def create_icontact( contact_object)
    url = URI.parse("#{ICONTACT_URL}/contacts")
    sock = get_sock(url)
    resp , get_data =  sock.post(url.path, contact_object , @headers)
    return resp
  end

  def self.get_contact_obj (email,firstName, lastName, phone, street, city, state, postalCode, createDate, password, user_login)
  return {"contacts"=> {"email"=>email , "firstName"=>firstName , "lastName"=>lastName, "phone"=>phone, "street"=>street, "city"=>city, "state"=>state, "postalCode"=>postalCode, "createDate"=>createDate, "username" => user_login, "password" => password}}.to_json
  end
 
  def add_contact_tolist(contact_id,list_id)
    url = URI.parse("#{ICONTACT_URL}/subscriptions")
    subscription_obj = {"subscriptions"=> {"contactId" => contact_id , "listId" => list_id , "status"=>"normal" }}.to_json
    sock = get_sock(url)
    resp , get_data =  sock.post(url.path, subscription_obj , @headers)
    return resp
  end

  def self.add_contact_from_userobj(user,password,is_new_user)
    begin
      logger=Logger.new("#{RAILS_ROOT}/log/icontact_list.log")
      logger.info " new contact #{user.email} "

      list_id = is_new_user ? user.get_list_id_for_new_user : user.get_list_id

      if list_id.nil?
        logger.info " User does not belong to any list and thus not added . User's email : #{user.email} "
        return
      end
      address, city, state, zipcode = self.get_company_info(user)

      icontact = self.new(ICONTACT_HTTP_HEADER)
      response_icontact = icontact.create_icontact(self.get_contact_obj(user.email, user.first_name, user.last_name, user.business_phone, address, city, state, zipcode, user.created_at,password,user.login))
      contact_hash = ActiveSupport::JSON.decode(response_icontact.body)
      logger.info " new contact id is  #{contact_hash["contacts"][0]["contactId"]} "
      icontact.add_contact_tolist(contact_hash["contacts"][0]["contactId"],list_id)
      logger.info " new contact is created : #{user.email} "
      logger.info " ============================= "
      return contact_hash
    rescue Exception=>exp
      if user.pending_icontact_user_list.blank?
        pending_icontact = PendingIcontactUserList.create(:user_id => user.id, :list_id_detail => new_list_id, :list_name => user.user_class.user_type)
      else
        user.pending_icontact_user_list.update_attributes(:is_processed => false)
      end
      logger.info " something went wrong "
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      logger.info " ============================= "
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Icontact")
    end
  end

  def self.update_contact_from_userobj(user)
    begin
      logger=Logger.new("#{RAILS_ROOT}/log/icontact_list.log")
      logger.info " update contact #{user.email} "
      icontact = self.new(ICONTACT_HTTP_HEADER)
      #find new list id
      new_list_id = user.get_list_id
      if new_list_id.nil?
        logger.info " User does not belong to any list and thus not added . User's email : #{user.email} "
        return
      end

      address, city, state, zipcode = self.get_company_info(user)
      #find the contact by user email
      contact_hash = icontact.find_contact_by_email(user.email)
      if contact_hash["contacts"].blank?
        logger.info " #{user.email} not found, so add this user to icontact list \n "
        new_user = self.add_contact_from_userobj(user, DEFAULT_PASS_FOR_FREE_CLASS, false)
        return
      end
      #update user info for basic user class
      if new_list_id == ICONTACT_HTTP_HEADER[:free_user_list_id]
        logger.info " update user info when moved to free user class "
        contact_obj = self.get_contact_obj_for_basic_user(user, address, city, state, zipcode)
        add_uname_pass = icontact.update_contact_in_icontact(contact_hash["contacts"][0]["contactId"],contact_obj)
      end
      #find subscription id with the help of contact id
      subscription_info = icontact.find_subscription_info(contact_hash["contacts"][0]["contactId"])
      #move user to another list
      if subscription_info["subscriptions"].blank?
        icontact.add_contact_tolist(contact_hash["contacts"][0]["contactId"],new_list_id)
      else
        move_contact = icontact.move_contact_to_new_list(user,subscription_info["subscriptions"][0]["subscriptionId"],new_list_id)
      end
      #log the info
      logger.info " update contact id is  #{contact_hash["contacts"][0]["contactId"]} "
      logger.info " contact is updated : #{user.email}, new list id : #{new_list_id} "
      logger.info " ============================= \n"
    rescue Exception=>exp
      if user.pending_icontact_user_list.blank?
        pending_icontact = PendingIcontactUserList.create(:user_id => user.id, :list_id_detail => new_list_id, :list_name => user.user_class.user_type)
      else
        user.pending_icontact_user_list.update_attributes(:is_processed => false)
      end
      logger.info " something went wrong "
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      logger.info " ============================= \n"
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Icontact")
    end
  end

  def find_contact_by_email(user_email)
    url = URI.parse("#{ICONTACT_URL}/contacts?email=#{user_email}")
    sock = get_sock(url)
    resp , get_data = sock.get(url.request_uri,@headers)
    return decode_json_into_hash(resp.body)
  end

  def find_subscription_info(contact_id)
    url = URI.parse("#{ICONTACT_URL}/subscriptions?contactId=#{contact_id}")
    sock = get_sock(url)
    resp , get_data = sock.get(url.request_uri,@headers)
    return decode_json_into_hash(resp.body)
  end

  def move_contact_to_new_list(user,subscription_id,new_list_id)
    url = URI.parse("#{ICONTACT_URL}/subscriptions/#{subscription_id}")
    subscription_obj = {"listId" => "#{new_list_id}"}.to_json
    sock = get_sock(url)
    resp , get_data = sock.put(url.request_uri,subscription_obj,@headers)
    return decode_json_into_hash(resp.body)
  end

  def update_contact_in_icontact(contact_id,contact_obj)
    url = URI.parse("#{ICONTACT_URL}/contacts/#{contact_id}")
    sock = get_sock(url)
    resp , get_data = sock.put(url.request_uri,contact_obj,@headers)
    return decode_json_into_hash(resp.body)
  end

  def self.get_company_info(user)
    user_company_info = user.user_company_info
    unless user_company_info.blank?
      address, city, state, zipcode = user_company_info.business_address, user_company_info.city, user_company_info.state, user_company_info.zipcode
    else
      address, city, state, zipcode = "", "", "", ""
    end
    return address, city, state, zipcode
  end

  def self.get_contact_obj_for_basic_user(user, address, city, state, zipcode)
    return { "email"=>user.email , "firstName"=>user.first_name , "lastName"=>user.last_name, "phone"=>user.business_phone, "street"=>address, "city"=>city, "state"=>state, "postalCode"=>zipcode, "createDate"=>user.created_at, "username" => user.login}.to_json
  end

  def self.process_to_add_icontact_pending_user_in_list
    begin
      logger=Logger.new("#{RAILS_ROOT}/log/icontact_list.log")
      delete_is_processed_users = PendingIcontactUserList.delete_all(:is_processed=>true)

      total_pending_icontacts = PendingIcontactUserList.count(:all)
      i = (total_pending_icontacts.to_f/BATCH_SIZE).ceil
      return if i == 0
      (1..i).each do |index|
        #Resque code
        offset = BATCH_SIZE*(index-1)
        Resque.enqueue(ProcessPendingIcontactUserListWorker,BATCH_SIZE,offset)
      end
    rescue Exception=>exp
      logger.info " something went wrong, not able to add user in icontact list "
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      logger.info " ============================= \n"
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Icontact")
    end
  end

  def self.add_pending_user_to_icontact(limit,offset)
    begin
      logger=Logger.new("#{RAILS_ROOT}/log/icontact_list.log")
      pending_icontact_user_lists = PendingIcontactUserList.find(:all, :limit => limit, :offset => offset)
      pending_icontact_user_lists.each do |pending_icontact_user|
        logger.info " ============================= \n move pending icontact user"
        user = pending_icontact_user.user
        pending_icontact_user.update_attributes(:is_processed => true)
        add_pending_user = self.update_contact_from_userobj(user)
        logger.info " pending icontact moved:- #{user.email} \n ============================= \n "
      end
    rescue Exception=>exp
      logger.info " something went wrong, not able to add user in icontact list "
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      logger.info " ============================= \n"
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Icontact")
    end
  end

  def self.add_user_to_your_site_done_for_you_list(user,list_id)
    begin
      logger=Logger.new("#{RAILS_ROOT}/log/icontact_list.log")
      logger.info " update contact #{user.email} "
      icontact = self.new(ICONTACT_HTTP_HEADER)
      #find the contact by user email
      contact_hash = icontact.find_contact_by_email(user.email)
      if contact_hash["contacts"].blank?
        logger.info " #{user.email} not found, so add this user to icontact list \n "
        contact_hash = self.add_contact_from_userobj(user, DEFAULT_PASS_FOR_FREE_CLASS, false)
      end
      #move user to do it for you
      icontact.add_contact_tolist(contact_hash["contacts"][0]["contactId"],list_id)
      #log the info
      logger.info " update contact id is  #{contact_hash["contacts"][0]["contactId"]} "
      logger.info " contact is updated : #{user.email}, new list id : #{list_id} "
      logger.info " ============================= \n"
    rescue Exception=>exp
      logger.info " something went wrong "
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      logger.info " ============================= \n"
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Icontact")
    end
  end

private

  def get_sock(url)
    sock = Net::HTTP.new(url.host, url.port)
    sock.use_ssl = true
    return sock
  end

  def decode_json_into_hash(resp)
    return ActiveSupport::JSON.decode(resp)
  end
end