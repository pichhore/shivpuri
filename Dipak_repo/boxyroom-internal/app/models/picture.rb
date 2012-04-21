class Picture < ActiveRecord::Base

  # relationships
  
  belongs_to :property

  has_attached_file :image,
    :styles => { :medium => ["650x550#", :png], :thumb => ["78x78#", :png], :middle => ["132x148^", :png], :small =>["48x48#", :png] },
    :default_url => "/images/missing/missing_:class_:style.png"
  
  validates_attachment_presence :image

  validates_attachment_content_type :image,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'],
    :message => "Only .jpg, .jpeg, .pjpeg, .gif, .png and .x-png image files are allowed"

#  validates_attachment_size :image,
#    :less_than => 5.megabytes,
#    :message => "max size is 1M"
end
