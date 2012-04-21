class Testimonial < ActiveRecord::Base
  uses_guid

  belongs_to :partner_account
  has_many :testimonial_pictures
  has_many :associate_testimonials

  default_scope :order => 'updated_at DESC'
end
