require 'digest/sha1'
class User < ActiveRecord::Base
    acts_as_xapian :texts => [ :first_name, :last_name ],
       :values => [ [ :created_at, 0, "created_at", :date ] ]
  
  uses_guid
  has_one  :twitter ,:class_name=>"TwitterToken", :dependent=>:destroy
  has_one :buyer_user_image, :dependent=>:destroy
  has_one :investor_website, :dependent=>:destroy
  has_many :seller_websites, :dependent=>:destroy
  has_many :user_transaction_histories, :dependent=>:destroy

  # has_many :buyer_web_pages, :dependent=>:destroy

  has_one :user_company_info, :dependent=>:destroy
  has_one :user_company_image, :dependent=>:destroy
  has_many :buyer_notification, :dependent=>:destroy
  has_many :investor_types, :dependent => :destroy
  has_many :feeds, :dependent => :destroy
  belongs_to :user_class
  has_many :user_territories, :dependent => :destroy
  has_many :profiles, :dependent => :nullify
  has_one :user_focus_investor
  has_many :lah_shopping_cart_user, :dependent => :destroy
  has_many :lah_product_purchased_by_users, :dependent => :destroy
  has_many :shopping_cart_order_transaction_failures, :dependent => :destroy
  has_one :map_lah_product_with_user, :dependent => :destroy
  has_many :shopping_cart_user_detail, :dependent => :destroy
  has_many :alerts, :conditions=>['alert_definitions.id is not null and (alert_definitions.deleted_at is null or alert_definitions.deleted_at > ?)', Time.now], :include => :alert_definition
  has_many :active_alerts, :class_name => 'Alert', :conditions => ['dismissed = ? and alert_definitions.id is not null and alert_definitions.disabled = ? and (alert_definitions.deleted_at is null or alert_definitions.deleted_at > ?)', false, false, Time.now], :include => :alert_definition, :order => "alerts.created_at DESC"
  
  has_many :email_alerts, :conditions=>['email_alert_definitions.id is not null and (email_alert_definitions.deleted_at is null or email_alert_definitions.deleted_at > ?)', Time.now], :include => :email_alert_definition, :dependent => :destroy

  has_many :email_alert_to_users, :conditions=>['user_email_alert_definitions.id is not null'], :include => :user_email_alert_definition, :dependent => :destroy

  has_many :digest_histories, :dependent => :destroy

  has_many :territories, :through=>:user_territories
  has_many :investor_messages,:foreign_key => "sender_id",:dependent => :destroy
  
  has_many :reciever_investor_messages,:source=>"investor_message",:through=>:investor_message_recipients, :foreign_key => "reciever_id",:dependent => :destroy
  has_many :investor_message_recipients,:foreign_key => "reciever_id",:dependent => :destroy
  has_many :badge_users, :dependent => :destroy

  has_many :seller_profiles, :dependent => :destroy
  has_one :seller_website, :dependent => :destroy
  has_many :my_websites, :dependent => :destroy
  has_many :site_users, :dependent => :destroy
  has_one :pending_icontact_user_list, :dependent => :destroy
  has_many :seller_responder_sequences, :dependent => :destroy
  has_many :user_focus_investors, :dependent => :destroy
  has_one :seller_magnet, :class_name => "SellerWebsite", :conditions => {:seller_magnet => true}, :dependent => :destroy 

  has_one :partner_account

  has_many :social_media_accounts, :dependent => :destroy

  # Virtual attribute for the unencrypted password
  attr_accessor :password 
  #attr_accessible :auto_syndication
  attr_accessor :profile_type_at_registration
  attr_accessor :terms_of_use
  attr_accessor :lah_product_id
  attr_accessor :is_user_cancel_subscriptn_or_move_with_failed_pay, :skip_last_name

 #Will paginate setting
   cattr_reader :per_page
   @@per_page = 10
   PRODUCT_TYPE = { :amps => "amps", :goldcoaching => "goldcoaching", :top1 => "top1", :re_volution => "revolution", :LAH => "LAH"}
  validates_presence_of     :user_class_id
  validates_presence_of     :email
  validates_presence_of     :first_name
  validates_presence_of     :login
  validates_presence_of     :license_number,             :if => :license_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100,:if => :email_provided?
  validates_uniqueness_of   :email, :case_sensitive => false,:if => :email_provided?, :message => "This email is already registered."
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:if => :email_provided?, :message => "Please enter valid email address."
  validates_acceptance_of   :terms_of_use, :message=>"You must agree to the terms of use"
  validates_numericality_of :number_of_territory, :allow_nil=>true ,:only_integer => true, :if => :validation_required?
  validates_presence_of     :complimentary_reason, :if => :validate?
  #validates_length_of :number_of_territory, :within => 1..3
  before_save :call_before_save
  before_create :make_activation_code
  after_save :refresh_profile_names, :if => "@is_session_controller.nil? && (self.first_name_changed? || self.last_name_changed?)"
  before_destroy :destroy_user_profile
  
  named_scope :missing_user_profile_images, :include => :buyer_user_image, :conditions =>   "buyer_user_images.id is not null"
  
  named_scope :find_user_by_id_or_login, lambda { |user_id, user_login| { :conditions => [ "id = ? OR login = ?", user_id, user_login] } }

  named_scope :get_canceled_users,lambda {|free_class_id| {:conditions => ["is_user_cancelled_membership = ? and user_class_id = ?", true,free_class_id], :order => "date_of_cancellation DESC"}}

  def get_individual_stick_rate
    get_duration = (self.subscription_days > 0) ? (self.subscription_days) : (Date.parse(self.date_of_cancellation.to_s) - Date.parse(self.created_at.to_s)).to_i
    ("%.2f" % ((get_duration.to_f)/30))
  end

  def validate?
      errors.add(:complimentary_reason, "can not be blank") and return if (self.test_comp == "comp" and self.complimentary_reason.blank? )
      errors.add(:complimentary_reason, "should be upto 100 characters in length") and return if (self.test_comp == "comp" and self.complimentary_reason.length > 100)
  end

  def validate_last_name?
    return false if skip_last_name && skip_last_name == true
    true
  end

  def investor_company_phone
    return !current_user.user_company_info.business_phone.blank? ? "#{current_user.user_company_info.business_phone}" : ""
  end

  def destroy_user_profile
    Profile.find_with_deleted(:all, :conditions => {:user_id => self.id}).each do |profile|
      profile.user_id = nil
      begin
        profile.skip_matches_update = true
        profile.save
        profile.skip_matches_update = false
      rescue
        profile.skip_matches_update = false
      end
      profile.destroy
      # Delete cached data and update match count
      profile_matches = ProfileMatchesDetail.match_exists?(profile)
      if !profile_matches.empty?
        profile.delete_profile_matches_data(profile_matches)
      end
    end
  end

  def is_basic_user?
    self.user_type == BASIC_USER_CLASS[:basic_type] ? true : false
  end

  def is_uc1_user?
    self.user_type == BASIC_USER_CLASS[:uc1_type] ? true : false
  end
  
  def is_pro_user?
    self.user_type == BASIC_USER_CLASS[:uc2_type] ? true : false
  end

  def can_view?
    if self.is_uc1_user?
       return true
    elsif self.is_basic_user?
       return true
    else
       return true
    end
  end

  def profile_completeness_with_todos
    todos = []
    completeness = 0

    weightages = {
      :buyer_user_image => 12,  :buyer_notification => 15, :user_company_info => 10, 
      :business_phone => 5, :about_me => 5, :user_focus_investor => 5, 
      :investing_since => 5, :real_estate_experience => 5, :fb_access_token => 5
    }
   
    todos_detail = {
      :buyer_user_image => {:text => "Add Profile Image", :link => "/account/profile_image"}, 
      :buyer_notification => {:text => "Configure Buyer Responder", :link => "/account_marketing/welcome_email"
      }, 
      :user_company_info => {:text => "Add Company Info", :link => "/account/company_info"}, 
      :business_phone => { :text => "Add Mobile Phone",:link => "/account/settings",:element => "user_business_phone"}, 
      :about_me => {:text => "Add About Me",:link => "/account/settings",:element => "user_about_me"},
      :user_focus_investor => {:text =>"Add Investor Focus",:link=>"/account/settings",:element=>"user_focus_investor_is_longterm_hold"},
      :investing_since => {:text =>"Add Investing Since",:link => "/account/settings",:element => "user[investing_since]"}, 
      :real_estate_experience => {:text =>"Add Real Estate Experience",:link=>"/account/settings",:element=>"user_real_estate_experience"},
      :fb_access_token => {:text =>"Add Facebook Syndication",:link=>"/account/property-syndication",:element=>"user_fb_access_token_url"}
    }

    weightages.each do |k,v|
      detail = self.send(k)
      if detail.blank?
        todos.push(todos_detail[k].merge({:percent => v})) 
      else
        if k == :user_focus_investor
          if detail.is_longterm_hold.blank? && detail.is_fix_and_flip.blank? && detail.is_wholesale.blank? && detail.is_lines_and_notes.blank?
            todos.push(todos_detail[k].merge({:percent => v})) 
            next
          end
        end
        completeness += v
      end
    end

    has_active_page = false
    inactive_webpage_url = nil    
    if !self.user_territories.blank?
      for territory in self.user_territories
        break if completeness == 100
        next if territory.buyer_web_page.blank?
        if territory.buyer_web_page.active?
          has_active_page = true
          completeness += 25
          break
        elsif inactive_webpage_url.blank?
          unless territory.buyer_web_page.domain_permalink_text.blank?
            inactive_webpage_url = "/buyer_websites/#{territory.buyer_web_page.id}/edit"
          end
        end
      end
    end

    todos.push({ :text => "Activate Buyer website", :link => inactive_webpage_url || "/buyer_websites/step1", :percent => 25 }) if has_active_page == false
    
    if self.social_media_accounts.find(:all, :conditions => ["url != '' AND (url_type_id = 1 OR url_type_id = 5)"]).blank?
      todos.push({:text=>"Add Facebook to your Profile",:link=>"/account/social_media",:percent=>2,:element=>"user_social_media_accounts_url"})
    else
      completeness += 2
    end
     
    if self.social_media_accounts.find(:all, :conditions => ["url != '' AND (url_type_id = 2 OR url_type_id = 6)"]).blank?
      todos.push({:text=>"Add  Linkedin to your Profile",:link=>"/account/social_media",:percent=>2,:element=>"user_social_media_accounts_url"})
    else
      completeness += 2
    end

    if self.social_media_accounts.find(:all, :conditions => ["url != '' AND (url_type_id = 3 OR url_type_id = 7)"]).blank?
      todos.push({:text=>"Add YouTube to your Profile",:link=>"/account/social_media",:percent=>2,:element=>"user_social_media_accounts_url"})
    else
      completeness += 2
    end
    
    if self.social_media_accounts.find(:all, :conditions => ["url != '' AND (url_type_id = 4 OR url_type_id = 8)"]).blank?
      todos.push({:text=>"Add Twitter to your Profile",:link=>"/account/social_media",:percent=>2,:element=>"user_social_media_accounts_url"})
    else
      completeness += 2
    end

    completeness = 100 if completeness >= 100    
    return completeness, todos
  end

  def user_type
   self.user_class ? user_class.user_type : ""
  end

  def user_type_name
   self.user_class ? user_class.user_type_name : ""
  end

  def refresh_profile_names
    # ticket #357 - need to force all profiles to update name in case the user changed their first/last name
    self.profiles.each do |profile|
      if profile.buyer? or profile.buyer_agent?
        begin
          profile.skip_matches_update = true
          profile.save!
          profile.skip_matches_update = false
        rescue
          profile.skip_matches_update = false
        end
      end
    end
  end

  def active_profiles
    Profile.find(:all, :joins => [:profile_field_engine_indices], 
                 :select => "DISTINCT profiles.*", :conditions => ["status = ? && profiles.user_id = ? && profiles.deleted_at IS NULL",'active', self.id])
  end

  def self.find_users_with_digest_frequency(interval)
    freq = "D"
    freq = "W" if interval == :weekly
    freq = "M" if interval == :monthly
    return self.find(:all, :conditions=>["digest_frequency = ?",freq])
  end

  def self.count_active_users(time)
    return self.count('id', { :conditions=>["DATE(created_at) <= '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_digest_daily(time)
    return self.count('id', { :conditions=>["digest_frequency = 'D' AND DATE(created_at) < '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_digest_weekly(time)
    return self.count('id', { :conditions=>["digest_frequency = 'W' AND DATE(created_at) < '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_pro_subscription_users(time)
    user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:uc2_type])
    return self.count('id', { :conditions=>["user_class_id = '#{user_class.id}' AND DATE(created_at) <= '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_plus_subscription_users(time)
    user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:uc1_type])
    return self.count('id', { :conditions=>["user_class_id = '#{user_class.id}' AND DATE(created_at) <= '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_free_subscription_users(time)
    user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:basic_type])
    return self.count('id', { :conditions=>["user_class_id = '#{user_class.id}' AND DATE(created_at) <= '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_failed_payment_users(time)
    return self.count('id', { :conditions=>["is_user_have_failed_payment = 1 AND DATE(created_at) < '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.count_digest_monthly(time)
    return self.count('id', { :conditions=>["digest_frequency = 'M' AND DATE(created_at) < '#{time.strftime("%Y-%m-%d")}' AND test_comp is null "]})
  end

  def self.find_all_users(end_date=nil)
    conditions = end_date.nil? ? nil : ["created_at <= ?", end_date]
    return self.find(:all, :conditions=>conditions, :order=>"first_name, last_name")
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.attributes = {:activated_at => Time.now.utc, :activation_code => nil}
    self.profiles.each do |profile|
      profile.xapian_mark_needs_index
    end
    save(false)
  end

  def territory_exists?(id)
    if territory = user_territories.find_by_territory_id(id)
      return true unless territory.buyer_web_page.nil?
    end
    return false
  end

  def activated?
    activation_code.nil?
  end

  def logged_in!
    @is_session_controller = true
    self.previous_login_at = self.last_login_at
    self.last_login_at = Time.now.utc
    save(false)
  end

  def full_name
      first_name.to_s + " " + last_name.to_s
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def get_list_id
    return nil if self.user_class.blank?
    return ICONTACT_HTTP_HEADER[:uc1_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:uc1_type]
    return ICONTACT_HTTP_HEADER[:canceled_user_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:basic_type]
    return ICONTACT_HTTP_HEADER[:new_uc2_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:uc2_type] and self.is_user_moved_to_new_pro_bucket
    return ICONTACT_HTTP_HEADER[:uc2_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:uc2_type]
    return nil
  end

  def get_list_id_for_new_user
    return nil if self.user_class.blank?
    return ICONTACT_HTTP_HEADER[:uc1_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:uc1_type]
    return ICONTACT_HTTP_HEADER[:free_user_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:basic_type]
    return ICONTACT_HTTP_HEADER[:new_uc2_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:uc2_type] and self.is_user_moved_to_new_pro_bucket
    return ICONTACT_HTTP_HEADER[:uc2_list_id] if self.user_class.user_type == BASIC_USER_CLASS[:uc2_type]
    return nil
  end

  # return email id for sending mail on behalf of user
  def investor_email_address
      return self.user_company_info.blank? ? self.email  :  self.user_company_info.business_email
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def self.admin_access_user(login)
    u = find :first, :conditions => ['login = ?', login]
  end

  def User.authenticate_by_token(id, token)
    begin
      u = find(:first, :conditions=>["id = ? AND security_token = ?", id, token])
      raise "Could not locate user with id=#{id} and token=#{token}" if u.nil?
      return nil if u.token_expired?
      u
    rescue 
      nil
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 1.year
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    @is_session_controller = true
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Forgot password support
  def generate_security_token(hours = nil)
    if not hours.nil? or self.security_token.nil? or self.security_token_expiry.nil? or
        (Time.now.to_i + token_lifetime / 2) >= self.security_token_expiry.to_i
      return new_security_token(hours)
    else
      return self.security_token
    end
  end

  def change_password(pass, confirm = nil)
    self.password = pass
    self.password_confirmation = confirm.nil? ? pass : confirm
    UserForumIntegration.change_password_on_forum(self.login, pass, self.password_confirmation) if RAILS_ENV == "production"
    # reset token so that a subsequent request won't be allowed
    self.security_token = nil
  end

  def change_password_for_forum(pass, confirm = nil)
    self.password = pass
    self.password_confirmation = confirm.nil? ? pass : confirm
    # reset token so that a subsequent request won't be allowed
    self.security_token = nil
  end

  # Forgot password support
  def token_expired?
    self.security_token and self.security_token_expiry and (Time.now > self.security_token_expiry)
  end

  # Forgot password support
  def new_security_token(hours = nil)
    write_attribute('security_token', self.class.hashed(self.crypted_password + Time.now.to_i.to_s + rand.to_s))
    write_attribute('security_token_expiry', Time.at(Time.now.to_i + token_lifetime))
    update_without_callbacks
    return self.security_token
  end

  # Forgot password support
  def self.hashed(str)
    return Digest::SHA1.hexdigest("dwellgo--#{str}--")[0..39]
  end

  def digest_daily?
    return self.digest_frequency == "D"
  end

  def digest_weekly?
    return self.digest_frequency == "W"
  end

  def digest_monthly?
    return self.digest_frequency == "M"
  end

  def admin?
    return (self.admin_flag == true)
  end

  def deliver_direct_message_immediately?
    return true if self.direct_message_frequency == 'I' # immediate delivery
    return false
  end

  def accepts_html?
    return (self.preferred_digest_format == 'html')
  end
  
  def to_label
    "#{self.first_name} #{self.last_name}"
  end
  
  def find_all_investors(territory_id, page_number)
    territory = Territory.find_by_id(territory_id)
    # return territory.users.paginate(:all,:page => page_number,:conditions=>["users.id <> ?",current_user.id], :order => 'activity_score desc')
    return territory.users.paginate(:all, :page => page_number, :order => 'activity_score desc', :include => [:buyer_user_image, :user_company_info, :badge_users])
  end
  
  def self.moving_user_to_free_class
    require 'spreadsheet'
    xls_path = "/home/deploy/Cancelled_Users_NEWg.xls"
    book = Spreadsheet.open xls_path
    sheet = book.worksheet 0
    user_class_id = UserClass.find_by_user_type("UC0").id
    sheet.each do |row|
      if !row[2].blank?
        user = User.find(:first,:conditions=>["email=?",row[2].to_s])
        user.update_attributes(:user_class_id=>user_class_id) if !user.blank?
      end
    end
  end


  def buyer_sites
    buyer_sites = []
    self.my_websites.each do |website|
      if website.site_type == "BuyerWebPage"
        buyer_sites << website
      end
    end
    return buyer_sites
  end

  def seller_sites
    seller_sites = []
    self.my_websites.each do |website|
      if website.site_type == "SellerWebsite"
        seller_sites << website
      end
    end
    return seller_sites
  end


  protected
 
   def call_before_save
    encrypt_password
    update_pass_for_icontact_free_class
    update_user_class_when_change
   end

   def update_user_class_when_change
    existing_user = User.find(:first, :conditions => ["id = ?", self.id])
    return if existing_user.blank?
    user_old_class = existing_user.user_class
    user_new_class = UserClass.find(:first, :conditions => ["id = ?",self.user_class_id])
    return if user_new_class.blank? or user_old_class.blank? or user_old_class.user_type == user_new_class.user_type
    if user_old_class.user_type == BASIC_USER_CLASS[:basic_type]
      self.last_subscription_date = Time.now
      self.is_user_cancelled_membership = 0
    elsif user_new_class.user_type == BASIC_USER_CLASS[:basic_type]
      self.date_of_cancellation = Time.now
      self.last_subscription_date = self.created_at if self.last_subscription_date.blank?
      duration = (self.date_of_cancellation.to_date - self.last_subscription_date.to_date).to_i
      self.subscription_days = duration.blank? ? self.subscription_days.to_i : (self.subscription_days.to_i + duration.to_i)
      self.cancellation_reason, self.user_class_before_cancellation, self.is_user_cancelled_membership = "Cancelled Manually by Admin Panel",user_old_class.user_type_name, 1
    end
   end
   
   def validation_required?
      errors.add(:number_of_territory, "should be upto 3 characters in length") if number_of_territory.to_s.length < 0 or number_of_territory.to_s.length > 3
   end


  def update_pass_for_icontact_free_class
     unless ICONTACT_HTTP_HEADER.blank?
       user_class = UserClass.find(:first,:conditions=>["id = ? ",self.user_class_id])
       return if user_class.blank?
       old_user = User.find(:first, :conditions => ["id=?",self.id])
       return if old_user.blank?
       old_user_type = old_user.user_class.blank? ? nil : old_user.user_class.user_type
       new_user_type = user_class.user_type
       old_user_class_name = old_user.user_class.blank? ? nil : old_user.user_class.user_type_name
       new_user_class_name = user_class.user_type_name
       if new_user_type !=  old_user_type 
         UserTransactionHistory.create(:user_id => self.id, :transanction_detail => "Customer moves from #{old_user_class_name} to #{new_user_class_name}") unless self.is_user_cancel_subscriptn_or_move_with_failed_pay
         Icontact.update_contact_from_userobj(self)
       end
     end
  end
    # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def email_provided?
      return !self.email.blank?
    end

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    # Forgot password support
    def token_lifetime
      48 * 60 * 60
    end
  
    def license_required?
      if !profile_type_at_registration.nil?
            profile_type_at_registration.buyer_agent? || profile_type_at_registration.seller_agent?
      end
    end

    def self.display_email_personalise_value_for_seller_res(current_user, text)
      investor_full_name = !current_user.blank? ? (!current_user.first_name.blank? ? "#{current_user.full_name}" : " " ) : " "
      investor_first_name = !current_user.blank? ? (!current_user.first_name.blank? ? "#{current_user.first_name}" : " ") : ""
      if !current_user.user_company_info.blank?
        business_name = !current_user.user_company_info.business_name.blank? ? "#{current_user.user_company_info.business_name}" : " "
        business_address = !current_user.user_company_info.business_address.blank? ? "#{current_user.user_company_info.full_address}" : " "
        business_phone = !current_user.user_company_info.business_phone.blank? ? "#{current_user.user_company_info.business_phone}" : " "
        business_email = !current_user.user_company_info.business_email.blank? ? "#{current_user.user_company_info.business_email}" : " "
      else
        business_name, business_address, business_phone, business_email = ' ', ' ', ' ', ' ', ' '
      end
      return text.to_s.gsub("{Company name}",business_name).gsub("{Company address}",business_address).gsub("{Company email}",business_email).gsub("{Company phone}",business_phone).gsub("{Investor full name}", investor_full_name).gsub("{Investor first name}", investor_first_name )
    end

    def self.display_email_personalise_value_for_buyer_res(current_user, text)
      investor_full_name = !current_user.blank? ? (!current_user.first_name.blank? ? "#{current_user.full_name}" : " " ) : " "
      investor_first_name = !current_user.blank? ? (!current_user.first_name.blank? ? "#{current_user.first_name}" : " ") : ""
      if !current_user.user_company_info.blank?
        business_name = !current_user.user_company_info.business_name.blank? ? "#{current_user.user_company_info.business_name}" : " "
        business_address = !current_user.user_company_info.business_address.blank? ? "#{current_user.user_company_info.full_address}" : " "
        business_phone = !current_user.user_company_info.business_phone.blank? ? "#{current_user.user_company_info.business_phone}" : " "
        business_email = !current_user.user_company_info.business_email.blank? ? "#{current_user.user_company_info.business_email}" : " "
      else
        business_name, business_address, business_phone, business_email = ' ', ' ', ' ', ' ', ' '
      end
      return text.to_s.gsub("{Company name}",business_name).gsub("{Company address}",business_address).gsub("{Company email}",business_email).gsub("{Company phone}",business_phone).gsub("{Investor full name}", investor_full_name).gsub("{Investor first name}", investor_first_name )
    end

    def self.display_email_assign_values(current_user, text)
      investor_full_name = !current_user.blank? ? (!current_user.first_name.blank? ? "#{current_user.full_name}" : "{Investor full name}") : ""
      investor_first_name = !current_user.blank? ? (!current_user.first_name.blank? ? "#{current_user.first_name}" : "{Investor first name}") : ""
      if !current_user.user_company_info.blank?
        business_name = !current_user.user_company_info.business_name.blank? ? "#{current_user.user_company_info.business_name}" : "{Company name}"
        business_address = !current_user.user_company_info.business_address.blank? ? "#{current_user.user_company_info.full_address}" : "{Company address}"
        business_phone = !current_user.user_company_info.business_phone.blank? ? "#{current_user.user_company_info.business_phone}" : "{Company phone}"
        business_email = !current_user.user_company_info.business_email.blank? ? "#{current_user.user_company_info.business_email}" : "{Company email}"
        retail_buyer_first_name = current_user.profiles.first ? (current_user.profiles.first.retail_buyer_profile ? current_user.profiles.first.retail_buyer_profile.first_name : "{Buyer first name}") : "{Buyer first name}"
      else
        business_name, business_address, business_phone, business_email, retail_buyer_first_name = '{Company name}', '{Company address}', '{Company phone}', '{Company email}', "{Buyer first name}"
      end
      return text.to_s.gsub("{Company name}",business_name).gsub("{Company address}",business_address).gsub("{Company email}",business_email).gsub("{Company phone}",business_phone).gsub('{Business Phone}',business_phone).gsub('{Business Address}',business_address).gsub('{Business Name}',business_name).gsub("{Investor full name}", investor_full_name).gsub("{Investor first name}", investor_first_name ).gsub("{Retail buyer first name}", retail_buyer_first_name).gsub("{Buyer first name}", retail_buyer_first_name).gsub("{eBook Download Link}","http://budurl.com/OwnerFinanceGuidev1")
    end

    def buyer_websites
      user_territories.map{|x| x.buyer_web_page if x.has_active_buyer_site?}.compact
    end
end
