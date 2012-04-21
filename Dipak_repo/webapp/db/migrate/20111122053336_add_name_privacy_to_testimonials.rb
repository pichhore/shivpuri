class AddNamePrivacyToTestimonials < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :name_private, :boolean, :defalut => false
    add_column :associate_testimonials, :name_private, :boolean, :defalut => false
  end

  def self.down
    remove_column :testimonials, :name_private
    remove_column :associate_testimonials, :name_private
  end
end
