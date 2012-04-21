class User < ActiveRecord::Base
    attr_accessor :change_password

    acts_as_authentic do |c|
    c.merge_validates_uniqueness_of_email_field_options(options = {:message=>"Your email address is already registered"})
    c.validates_length_of_email_field_options :in => 6..255, :allow_nil => true, :message=>"Your email must be more than 5 character"
    c.validates_format_of_email_field_options :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,  :message=>"Your email address doesn't look correct"
   c.validates_length_of_password_field_options :in => 4..255, :allow_nil => true, :message=>"Your password must be more than 3 characters" , :if => Proc.new{|f| f.check_value_type}
   c.validates_confirmation_of_password_field_options(options = {:message=>"Your password and password confirmation must be the same", :if => Proc.new{|f| f.check_value_type}})
   c.validates_length_of_password_confirmation_field_options :in => 4..255, :allow_nil => true, :message=>"Your password confirmation must be more than 3 characters" , :if => Proc.new{|f| f.check_value_type}
  end
  # validation for accept terms and policy before sign up
  validates_acceptance_of :terms_and_policy, :message=> "Please Accept the \'Terms of Use\' and \'Privacy Policy\'."

  validates_length_of :phone_no, :mobile_no, :fax_no, :within => 2..16, :allow_nil => true
  validates_length_of :first_name, :within => 2..64, :allow_nil => true, :message=> "Your first name must be more than 1 character"
  validates_length_of :last_name, :within => 2..64, :allow_nil => true, :message=> "Your last name must be more than 1 character"
  validates_format_of :first_name, :with => /^[-a-z-A-Z\d\s\_a_z_A_Z]*$/, :message => "Your first name must have characters [ 0-9, a-z, A-Z,  -,  _ ]."
  validates_format_of :last_name, :with => /^[-a-z-A-Z\d\s\_a_z_A_Z]*$/, :message=>"Your last name must have characters [ 0-9, a-z, A-Z,  -,  _ ]."
  
  validates_presence_of :first_name, :message=>"Enter your first name."
  validates_presence_of :last_name, :message=>"Enter your last name."
  # relationships

  has_many :roles

  has_many :applications
  has_many :received_applications, :through => :properties, :source => :applications
#   has_many :profiles, :through => :applications
  
  has_many :participating_threads, :class_name => "MessageThread", :foreign_key => "participant_id"
  has_many :owned_threads, :class_name => "MessageThread", :foreign_key => "owner_id"

  has_many :sent_messages, :class_name => "Message", :foreign_key => "sender_id"
  has_many :received_messages, :class_name => "Message", :foreign_key => "recipient_id"

  has_many :properties
  has_many :applied_properties, :through => :applications, :source => :property

  has_attached_file :avatar,
    :styles => { :medium => ["148x148#", :png], :thumb => ["48x48#", :png], :middle => ["78x78#", :png] },
    :default_url => "/images/missing/missing_:class_:style.png", :message => "Only .jpg, .jpeg, .pjpeg, .gif, .png and .x-png image files are allowed"






  # has_messages

  # validations

#   validates_presence_of :first_name, :message=> "Enter your first name"
#   validates_presence_of :last_name, :message=> "Enter your last name"
#   validates_presence_of :email, :message=> "Enter your email"
#   validates_presence_of :password, :on => :create,:message=> "Enter your password"
#   validates_presence_of  :password_confirmation, :on => :create,:message=> "Enter your password confirmation "



#   validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,:message=>""
#   validates_uniqueness_of :email

  validates_inclusion_of :gender, :in => My::AccountsHelper::OPTIONS_FOR_GENDER.map { |o| o.first.to_s }, :allow_nil => true

  validates_date :birth_date, :before => 12.years.ago, :allow_nil => true

  validates_attachment_content_type :avatar,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'], :message => "Only .jpg, .jpeg, .pjpeg, .gif, .png and .x-png image files are allowed"


  validates_attachment_size :avatar,
    :less_than => 1.megabyte,
    :message => "Max image size is 1MB"

  # preferences
  preference :currency, :string, :default => "SGD"

  # helpers

  def full_name
    "#{first_name} #{last_name.first}."
  end

  def full_name_profile
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def auto_fill_application?
    applications.size > 0
  end

  def auto_fill_application(property)
#     latest_profile = profiles.all.sort_by(&:updated_at).last
    latest_application = applications.all.sort_by(&:updated_at).last

    application = property.applications.new do |a|
      a.reason_for_leaving = latest_application.reason_for_leaving
    end

    application.card = latest_application.card.try(:clone) || Card.new
    application.landlord = latest_application.landlord.try(:clone) || Card.new

    application.profile = latest_application.profile

    application.profile.superior ||= Card.new
    application.profile.guardian ||= Card.new

    return application

  end

  def each_thread_with_last_message(&block)
    return if !block_given?

    all_threads.each do |thread|
      next if thread.messages.empty?
      yield thread, thread.messages.last
    end
  end

  def all_threads
    owned_threads.all + participating_threads.all
  end
  
  def open_trans?
    # open transactions - are there any pending transactions, paid transactions
    # on application?

    # iterate through applications
    self.applications.each do |a|
      if a.paid?
        return true
      end
    end
    return false
  end
  # actions

  def activate!
    self.reset_perishable_token!

    self.active_will_change!
    self.active = true
    self.save
  end

  def active?
    self.active && !self.suspended?
  end

  # for declarative authorization
  
  def role_symbols
    (roles || []).map {|r| r.title.underscore.to_sym}
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Delayed::Job.enqueue EmailJob.new(:deliver_password_reset_instructions!, self)
  end
  
  def check_value_type
    return self.change_password
  end
end
