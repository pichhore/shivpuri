class PropertyDoc < ActiveRecord::Base
  # relationships

  belongs_to :property

  has_attached_file :document,
    :styles => { :medium => ["650x340^", :png], :thumb => ["78x78#", :png], :middle => ["150x130#", :png] },
    :default_url => "/images/missing/missing_:class_:style.png"

    validates_attachment_presence :document

    validates_attachment_content_type :document,
      :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'], :message => "Only .jpg, .jpeg, .pjpeg, .gif, .png and .x-png image files are allowed"

    named_scope :find_properties,lambda{|property_id| {:conditions=>["property_id=?", property_id]}}

end
