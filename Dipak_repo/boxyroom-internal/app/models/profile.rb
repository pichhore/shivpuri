class Profile < ActiveRecord::Base

  attr_reader :value_type

  # relationships

  belongs_to :application

  has_one :current_address, :as => :addressable
  has_one :company, :as => :addressable
  belongs_to :country, :foreign_key => "country_of_issue"

  has_attached_file :photo, :styles => { :medium => ["300x300^", :png], :thumb => ["48x48#", :png] }, :default_url => "/images/missing/missing_:class_:style.png"
  has_attached_file :identification, :styles => { :medium => ["300x300^", :png] }, :default_url => "/images/missing/missing_:class_:style.png"

  belongs_to :guardian, :class_name => "Card", :foreign_key => "guardian_id"
  belongs_to :superior, :class_name => "Card", :foreign_key => "superior_id"

  accepts_nested_attributes_for :superior
  accepts_nested_attributes_for :guardian

  # validations

#   validates_inclusion_of :identification_type, :in => My::TenantApplicationsHelper::OPTIONS_FOR_IDENTIFICATION_TYPE.map { |o| o.first.to_s }

#   validates_date :expiry_date, :after => 1.week.from_now

#   validates_attachment_presence :photo
#   validates_attachment_presence :identification

  validates_attachment_content_type :photo,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'],
    :message => "Only image files are allowed"

#  validates_attachment_size :photo,
#    :less_than => 1.megabyte,
#    :message => "max size is 1M"

  validates_attachment_content_type :identification,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'], :message => "Only .jpg, .jpeg, .pjpeg, .gif, .png and .x-png image files are allowed"

#  validates_attachment_size :identification,
#    :less_than => 1.megabyte,
#    :message => "max size is 1M"

  # helper methods

  def value_type= value_type
    self.type = value_type.gsub("-", "_").camelize
  end

  def value_type
    return self.type.to_s if !self.new_record?
    self.type.tableize.singularize.gsub("_", "-")
  end

  def study_profile_type?
    self.type.to_s == "StudyProfile"
  end

  def business_profile_type?
    self.type.to_s == "BusinessProfile"
  end

  def travel_profile_type?
    self.type.to_s == "TravelProfile"
  end

end
