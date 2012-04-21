class InvestorWebsiteImage < ActiveRecord::Base

  THUMBS = { :profile => 200, :medium => 60, :tiny => 50 }
  uses_guid
  has_attachment :storage => :file_system, :max_size => 3.megabytes, :content_type => :image, :path_prefix => "public/#{table_name}/", :partition => false
  validates_as_attachment

  def find_profile_thumbnail
    InvestorWebsiteImage.find(:first, :conditions=>["parent_id = ? and thumbnail = 'profile'", self.id])
  end

  def find_medium_thumbnail
    InvestorWebsiteImage.find(:first, :conditions=>["parent_id = ? and thumbnail = 'medium'", self.id])
  end

  def find_tiny_thumbnail
    InvestorWebsiteImage.find(:first, :conditions=>["parent_id = ? and thumbnail = 'tiny'", self.id])
  end

  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    File.join(RAILS_ROOT, file_system_path, self.id.to_s, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

#   validates_uniqueness_of :user_id
# We handle our own thumbnail generation
  after_attachment_saved do |photo|
    if photo.parent_id.nil?
      THUMBS.each_pair do |file_name_suffix, size|
        thumb = thumbnail_class.find_or_initialize_by_thumbnail_and_parent_id(file_name_suffix.to_s, photo.id)
        resized_image = photo.crop_resized_image(size)
        thumb_file = File.open("#{RAILS_ROOT}/public/#{table_name}/#{thumb.parent_id}/#{photo.thumbnail_name_for(file_name_suffix.to_s)}", 'w+')
        resized_image.write(thumb_file)
        unless resized_image.nil?
          thumb.attributes = {
            :content_type    => photo.content_type,
            :filename        => photo.thumbnail_name_for(file_name_suffix.to_s),
            :size => resized_image.to_blob.length,
            :width => resized_image.columns,
            :height => resized_image.rows,
            :investor_website_id => photo.investor_website_id
          }
          thumb.save!
          # GC here?
          resized_image = nil
          thumb_file.close
          GC.start
        end
      end
    end
  end

  def crop_resized_image(size)
    thumb = nil
    with_image do |img|
      thumb =img.change_geometry!("#{size}x#{size}") { |cols, rows, image|
          image.resize!(cols, rows)
        }
      # thumb = img.resize!(size, size)
      #thumb = img.crop_resized(size, size)
      # GC here?
      img = nil
      GC.start
    end
    thumb
  end

  def self.find_investor_website_image(investor_website_id)
    investor_website_image = self.find_by_investor_website_id(investor_website_id)
    return investor_website_image.blank? ? self.new : investor_website_image
  end
end
