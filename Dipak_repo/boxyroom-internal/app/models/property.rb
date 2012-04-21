class Property < ActiveRecord::Base
  include AASM

  attr_accessor :action_flag
  validate :property_creation_date
#   validate :check_min_max_rental_period
  def property_creation_date
       unless self.action_flag
          errors.add( "available_at","Available from Date must be after #{Date.today} in Rental Details") if available_at <= Date.today 
       end
  end

#   def check_min_max_rental_period
#        errors.add( "Max Rental period must be less than min rental period") if max_rental_period < rental_period
#   end

  # relationships
  has_many :like_properties
  has_many :reviews

  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  has_many :applications, :extend => ApplicationsExtension
  has_many :users, :through => :applications
  has_many :pictures, :dependent => :destroy
  has_many :property_docs, :dependent => :destroy
  has_one :address, :as => :addressable

  acts_as_mappable :through => :address

  accepts_nested_attributes_for :property_docs, :allow_destroy => true
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  has_one :review, :dependent => :destroy


  # validations


#   validates_presence_of :title, :message =>"Enter title."
#   validates_presence_of :description, :message =>"Enter description in"
#   validates_presence_of :rental_period, :message =>"Enter rental period."
#   validates_presence_of :monthly_rental, :message =>"Enter monthly rental"
#   validates_presence_of :occupancy, :message =>"Enter occupants"


  validates_numericality_of :rental_period, :greater_than => 0, :only_integer => true, :allow_nil => true, :message=>"Rental period must be a number greater than 0 in Rental Details."
  validates_numericality_of :occupancy, :greater_than => 0, :only_integer => true, :allow_nil => true, :message => "Ocuupants must be a number greater than 0 in Rental Details."
  validates_numericality_of :rooms, :greater_than => 0, :only_integer => true, :allow_nil => true, :message => "Rooms must be a number greater than 0 in Property Details."
  
  validates_numericality_of :monthly_rental, :greater_than => 0, :message => "Monthly rental must be a number greater than 0 in Rental Details."
  validates_numericality_of :floor_area, :greater_than => 0, :allow_nil => true, :message => "Floor area must be a number greater than 0 in Property Details."

  validates_length_of :title, :within => 16..96, :allow_nil => true, :message => "Title must be greater than 15 characters in Property Details."
  validates_length_of :description, :within => 16..1200, :allow_nil => true, :message => "Description must be greater than 15 characters in Property Details."

  validates_associated :address, :pictures,:property_docs

  validates_inclusion_of :unit, :in => PropertiesHelper::OPTIONS_FOR_UNIT.map { |o| o.first.to_s }, :allow_nil => true
  validates_inclusion_of :category, :in => PropertiesHelper::OPTIONS_FOR_CATEGORY.map { |o| o.first.to_s }, :allow_nil => true

  before_validation :process_saved_images
  after_validation :temp_upload

  # scopes

  named_scope :not_delisted, :conditions => ['status !=?', "delisted"]
  named_scope :listed, :conditions => {:status => "listed"}
  named_scope :pending_approval,
    :joins => :owner,
    :conditions => ["status = ? AND users.suspended != ?", 'pending', true]
    
  # to get the properties which have listed status
  named_scope :approved_listing,
    :joins => [:owner],
    :conditions => ["status = ? AND users.suspended != ? AND properties.id not in (SELECT DISTINCT properties.id FROM properties INNER JOIN property_docs ON properties.id=property_docs.property_id WHERE ((properties.verified != 'verified' OR properties.verified is NULL) )) ", "listed", true]
  
  #named_scope :approved_listing,
   # :joins => [:owner],
    #:conditions => ["status = ? AND users.suspended != ?", "listed", true]
    
     

  # to get all properties those have non-verified documents
  def self.pending_document_verification
    sql_query = "SELECT DISTINCT properties.* FROM properties INNER JOIN users ON users.id = properties.user_id INNER JOIN property_docs ON properties.id=property_docs.property_id  WHERE ( properties.status = 'listed' AND users.suspended != 1 AND (properties.verified != 'verified' OR properties.verified is NULL) )"    
    Property.find_by_sql(sql_query)    
  end
    
#  named_scope :pending_verified,
#  :joins => :owner,
#     :conditions => ["verified != ? AND users.suspended != ?", true, true]
# 
#  named_scope :all_listings,
#  :joins => :owner,
#     :conditions => [ "users.suspended != ?", true]

  # state machine
  
  
  aasm_column :status
  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :listed
  aasm_state :rejected
  aasm_state :paid
  aasm_state :withdraw_pending
  aasm_state :occupied
  aasm_state :delisted

  aasm_event :approve do
    transitions :to => :listed, :from => [:pending], :guard => :can_approve?
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [:pending, :listed], :guard => :can_reject?
  end

  aasm_event :resubmit do
    transitions :to => :pending, :from => [:rejected], :guard => :can_resubmit?
  end

  aasm_event :pay do
    transitions :to => :paid, :from => [:listed], :guard => :can_pay?
  end

  aasm_event :relist do
    transitions :to => :pending, :from => [:delisted], :guard => :can_relist?
  end

  aasm_event :delist do
    transitions :to => :delisted, :from => [:listed], :guard => :can_delist?
  end

  aasm_event :submit_token do
    transitions :to => :withdraw_pending, :from => [:paid], :guard => :can_widthdraw?
  end

  aasm_event :payment_transferred do
    transitions :to => :occupied, :from => [:withdraw_pending], :guard => :can_transfer?
  end
  
  def editable?
    pending? || listed? || rejected? || delisted?
  end

  def can_approve?
    pending? && !self.owner.suspended?
  end

  def can_reject?
    pending? || listed?
  end

  def can_resubmit?
    rejected?
  end

  def can_pay?
    listed?
  end

  def can_relist?
    delisted?
  end

  def can_delist?
    listed?
  end
  
  def can_widthdraw?
    paid?
  end
  
  def can_transfer?
    withdraw_pending?
  end
  
  # helper methods
  
  def token_received_notification
    self.action_flag = true
    self.submit_token!
    unless self.save(false)
      return false
    end
    return true
  end

  def send_widthraw_notification
    self.action_flag = true
    self.payment_transferred!
    application = Application.find(:all, :conditions=>["property_id=?  and  status = ?", self.id, 'moved_in'])
    app = Application.find(application[0].id)
    unless self.save!
      return false
    end
    app.payment_transfer_status = true
    app.payment_transfer_date = Time.now
    app.payment_token = nil
    app.save(false)
    return true
  end

  def paid_application
    applications.each do |app|
      return app if app.paid?
    end
    nil
  end

  def display_category
    PropertiesHelper::OPTIONS_FOR_CATEGORY[category.to_sym]
  end

  def can_receive_payment?
    if paid?
        application = self.applications.find_by_status("paid")
        return true if !application.blank? and !application.payment_transfer_status
    end
    return false
  end

  def self.most_liked(properties)
    sort_by_has_many(properties, "like_properties" )
  end

  def self.most_reviewed(properties)
    #sort_by_has_many(properties, "like_properties" )
    arr, array, new_class = Array.new, Array.new, Struct.new(:obj,:score)
    properties.each{ |obj| arr.push(new_class.new(obj, obj.reviews.size)) }
    sort_by_score = arr.sort_by{|e| e.score}.reverse
    sort_by_score.each {|pr| array.push(pr.obj)}
    return array
  end

  def self.sort_by_has_many(objects, has_many_association)
    arr, array, new_class = Array.new, Array.new, Struct.new(:obj,:score)
    objects.each{ |obj| arr.push(new_class.new(obj, obj.like_properties.size)) }
    sort_by_score = arr.sort_by{|e| e.score}.reverse
    sort_by_score.each {|pr| array.push(pr.obj)}
    return array
  end


  private

  def sort_by_has_many(objects, assocation)
    arr, array, new_class = Array.new, Array.new, Struct.new(:prop,:score)
    objects.each{ |obj| arr.push(new_class.new(obj, obj.like_properties.size)) }
    sort_by_score = arr.sort_by{|e| e.score}.reverse
    sort_by_score.each {|pr| array.push(pr.prop)}
    return array
  end


  def process_saved_images
    if !self.previous_upload.blank? || !pictures.blank?
      directory = "tmp/"
      return true if self.previous_upload.blank?
      self.previous_upload.split(' ').each do |name|
		    logger.debug "MY PREVIOUS UPLOAD IS >>> #{previous_upload}"
		    path = File.join(directory, name)
		    @image = File.open(path)
		    logger.debug "WHAT!!!!!!!!!!!!!!!!!!! #{pictures.inspect}"
		    pictures.build(:image => @image)
      end
    end
    true
  end

  

  def temp_upload
    # no provisions for multiple file attachment
    if errors.empty? # if valid?
        true
    else # if errors
     return true if self.previous_upload.blank?
      pictures.each_with_index do |pic, index|
	     if pic.valid? && !self.previous_upload.include?(pic.image_file_name)
	       directory = "tmp/"
	       name = pic.image_file_name
	       name = Time.now.hash.to_s + "_" +  pic.image_file_name
	       path = File.join(directory, name)

	       # lets write!
	       File.open(path, "wb") { |f|
	         f.write(pic.image.queued_for_write[:original].read)
	       }
	       self.previous_upload = self.previous_upload + " " + name
         logger.debug "I WAS HERE#{previous_upload.inspect}"
	     end
      end # end pictures.each iteration
      pictures.clear
    end
  end
end
