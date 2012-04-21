class ReivewPropertyPicture < ActiveRecord::Base
  belongs_to :review
  has_attached_file :image
  validates_attachment_presence :image
  validates_attachment_content_type :image,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'],
    :message => "only image files are allowed"
end
