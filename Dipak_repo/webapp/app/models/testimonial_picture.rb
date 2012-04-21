class TestimonialPicture < ActiveRecord::Base
  has_attachment :storage => :file_system, :max_size => 3.megabytes, :content_type => :image, :path_prefix => "public/#{table_name}/"

  belongs_to :testimonial
  validates_as_attachment
end
