class AddColumnsToTestimonials < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :market_release, :boolean, :default => true
    add_column :testimonials, :other_tools, :string
    add_column :testimonials, :sales_estimate, :boolean, :default => false
    add_column :testimonials, :picture_types, :string
  end

  def self.down
    remove_column :testimonials, :market_release
    remove_column :testimonials, :other_tools
    remove_column :testimonials, :sales_estimate
    remove_column :testimonials, :picture_types
  end
end
