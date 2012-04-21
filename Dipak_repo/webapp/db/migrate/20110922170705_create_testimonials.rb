class CreateTestimonials < ActiveRecord::Migration
  def self.up
    exists = Testimonial.table_exists? rescue false
    if !exists
      transaction do
        create_table :testimonials, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :investor_fname,            :string
          t.column :investor_lname,            :string
          t.column :email,                     :string
          t.column :phone_number,              :string
          t.column :address,                   :string
          t.column :closing_date,              :datetime
          t.column :strategies,                :string
          t.column :sales_price,               :integer
          t.column :gross_profit,              :integer
          t.column :cash_flow,                 :integer
          t.column :deal_source,               :text
          t.column :problems_faced,            :text
          t.column :tools_used,                :string
          t.column :comments,                  :text
          t.column :lessons_or_tips,           :text
        
          t.timestamps
        end
        
        execute "ALTER TABLE testimonials ADD PRIMARY KEY (id)"
      end
    end
  end
    
  def self.down
    exists = Testimonial.table_exists? rescue false
    if exists
      transaction do
        drop_table :testimonials
      end
    end
  end
end
