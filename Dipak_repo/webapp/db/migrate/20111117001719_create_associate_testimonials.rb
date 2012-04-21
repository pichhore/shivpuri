class CreateAssociateTestimonials < ActiveRecord::Migration
  def self.up
    exists = AssociateTestimonial.table_exists? rescue false
    if !exists
      transaction do
        create_table :associate_testimonials, :options => 'ENGINE=MyISAM' do |t|
          t.column :testimonial_id,       :string, :limit => 36, :null => false, :references => :testimonials
          t.column :firstname,            :string
          t.column :lastname,             :string
          t.column :state,                :string
          t.column :likes,                :text
          t.column :suggestions,          :text
          t.column :mkt_release,          :boolean, :default => false
          t.column :closing_date,         :datetime
          t.column :sales_price,          :integer
          t.column :tx_comments,          :text
          t.column :type,                 :string

          t.timestamps
        end
      end
    end
  end

  def self.down
    exists = AssociateTestimonial.table_exists? rescue false
    if exists
      transaction do
        drop_table :associate_testimonials
      end
    end
  end
end
