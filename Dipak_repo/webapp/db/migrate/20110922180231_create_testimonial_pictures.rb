class CreateTestimonialPictures < ActiveRecord::Migration
  def self.up
    exists = TestimonialPicture.table_exists? rescue false
    if !exists
      transaction do
        create_table :testimonial_pictures do |t|
          t.column :testimonial_id, :string, :limit => 36, :null => false, :references => :testimonials

          t.column "content_type", :string
          t.column "filename", :string
          t.column "size", :integer

          t.column "parent_id", :string, :limit => 36, :references => nil
          t.column "thumbnail", :string
          t.timestamps
        end
      end
    end
  end

  def self.down
    exists = TestimonialPicture.table_exists? rescue false
    if exists
      transaction do        
        drop_table :testimonial_pictures
      end
    end
  end
end
