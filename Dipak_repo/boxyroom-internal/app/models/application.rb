class Application < ActiveRecord::Base
  include AASM

  attr_accessor :card_number, :card_verification

  named_scope :apps_with_status, lambda { |status| { :conditions => ["status = ?", status]}}
  named_scope :limited, lambda { |num| {:limit => num } }
  named_scope :new_applications_by_me, lambda { |days| { :conditions => ["updated_at > ?", days]}}
  # relationships
  has_one :credit_card_information
  
  belongs_to :user
  belongs_to :property

  has_one :profile, :dependent => :destroy

  has_many :transactions, :class_name => "ApplicationTransaction", :dependent => :destroy
  has_one :billing_address, :class_name => "Address", :as => :addressable, :dependent => :destroy

  belongs_to :card
  belongs_to :landlord, :class_name => "Card", :foreign_key => "landlord_id"

  accepts_nested_attributes_for :billing_address, :allow_destroy => true
  accepts_nested_attributes_for :profile, :allow_destroy => true
  accepts_nested_attributes_for :card, :allow_destroy => true
  accepts_nested_attributes_for :landlord, :allow_destroy => true
 
  has_one :review, :dependent => :nullify

  # scopes

  named_scope :cancelled, :conditions => ['status = ?', "cancelled"]
  named_scope :available, :conditions => ['status <> ?', "cancelled"]
  named_scope :approved, :conditions => {:status => "approved"}
  named_scope :pending, :conditions => {:status => "pending"}

  named_scope :paid, :conditions => {:status => "paid"}
  named_scope :to_refund, :conditions => {:to_refund => true}

  # validations
  validates_presence_of :expected_arrival,:message=>"Enter expected arrival date."
  validates_presence_of  :duration_of_stay,:message=>"Enter duration of stay."
  # validates_presence_of  :reason_for_leaving,:message=>"Enter reason for Moving."
  validates_uniqueness_of :property_id, :scope => :user_id
  validates_uniqueness_of :transaction_id
  validates_numericality_of :duration_of_stay, :only_integer => true, :allow_nil => true, :greater_than => 0, :message=>"Duration of stay must be a number."

  #validates_length_of :reason_for_leaving, :within => 16..320, :allow_nil => true, :message=>"Reason for Moving must be more than 15 characters."

   validate :check_expected_arrival_date
  def  check_expected_arrival_date
     errors.add("expected_arrival","Expected arrival must be after #{self.property.available_at}") if expected_arrival < self.property.available_at
   end
  validates_presence_of :approved_at, :if => :approved?

  #  validates_presence_of :first_name, :last_name, :ip_address, :card_type, :card_expires_on, :card_number, :card_verification, :if => :paid?
  #  validates_inclusion_of :card_type, :in => My::TenantApplicationsHelper::OPTIONS_FOR_CARD_TYPE.map { |o| o.first.to_s }, :if => :paid?
  #  validates_numericality_of :card_number, :card_verification, :only_integer => true, :allow_nil => true, :if => :paid?

  validates_associated :profile, :billing_address, :card, :landlord

  before_validation_on_create :create_transaction_id

  # state machine

  aasm_column :status
  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :approved
  aasm_state :paid

  aasm_state :rejected
  aasm_state :cancelled
  aasm_state :refunded
  aasm_state :revised

  aasm_state :moved_in
  
  
  aasm_event :movein do
    transitions :to => :moved_in, :from => [:paid], :guard => :movein?
  end
  
  aasm_event :approve do
    transitions :to => :approved, :from => [:pending], :guard => :can_approve?
  end

  aasm_event :pay do
    transitions :to => :paid, :from => [:approved], :guard => :can_pay?
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [:pending, :approved], :guard => :can_reject?
  end

  aasm_event :cancel do
    transitions :to => :cancelled, :from => [:approved, :pending], :guard => :can_cancel?
  end

  aasm_event :resend do
    transitions :to => :pending, :from => [:cancelled, :refunded, :rejected], :guard => :can_resend?
  end

  aasm_event :refund do
    transitions :to => :refunded, :from => [:paid], :guard => :can_refund?
  end

  aasm_event :revise do
    transitions :to => :pending, :from => [:approved], :guard => :can_revise?
  end

  def movein?
    paid?
  end

  def can_approve?
    pending? && can_show?
  end

  def can_pay?
    approved? && first_to_pay?
  end

  def can_reject?
    pending? || approved?
  end

  def can_cancel?
    pending? || approved?
  end

  def can_resend?
    (cancelled? || rejected? || refunded? ) &&  self.property.listed?
  end

  def can_refund?
    paid?
  end

  def can_revise?
    approved?
  end

  def can_edit?
    !approved? && ( cancelled? || rejected? || refunded? &&  self.property.listed? )
  end
  # helpers

  def purpose
    case profile.value_type
    when "StudyProfile" then "Study"
    when "BusinessProfile" then "Business"
    when "TravelProfile" then "Travel"
    end
  end

  def make_payment!
    price_in_cents = property.monthly_rental * 100

    # update property and application states
    Application.transaction do
      transactions.create!(:action => "purchase", :amount => price_in_cents)

      self.paid_at = Time.now
      self.pay!

      property.pay!

      save!
    end

    if paid? && property.paid?
      # reject other applicants
      property.applications.reload
      property.applications.reject_all!
    else
      return false
    end
  end

  def make_payment_!(application,payment_token)
    price_in_cents = property.monthly_rental * 100

    # update property and application states
    Application.transaction do
      transactions.create!(:action => "purchase", :amount => price_in_cents )

      self.paid_at = Time.now
      self.payment_token = payment_token
      self.pay!

      property.pay!

      save(false)
    end

    if property.paid?
      # reject other applicants
      property.applications.reload
      property.applications.reject_all!
    else
      return false
    end
  end

  def create_transaction_id
    generated_id = rand(36**6).to_s(36)
    attempts = 0

    while (attempts < 3)
      if !Application.exists?(:transaction_id => generated_id)
        break
      else
        generated_id = rand(36**6).to_s(36)
        attempts += 1
      end
    end

    self.transaction_id = generated_id
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end

  def can_show?
    if (self.pending? || self.approved?) && self.user.suspended? && !paid?
      return false
    end
      return true
  end

  # custom validation

  private

  def first_to_pay?
    property.applications.each do |a|
      next if a == self
      return false if (a.paid? or a.moved_in?)
    end
    
    true
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => card_type,
      :number             => card_number,
      :verification_value => card_verification,
      :month              => card_expires_on.month,
      :year               => card_expires_on.year,
      :first_name         => first_name,
      :last_name          => last_name
    )
  end

  def purchase_options
    {
      :ip => ip_address,
      :billing_address => {
      :name     => "#{first_name} #{last_name}",
      :address1 => "#{billing_address.unit_no} #{billing_address.street_name}",
      :city     => billing_address.city,
      :state    => billing_address.state,
      :country  => "SG",
      :zip      => billing_address.postal_code
      }
    }
  end



end
