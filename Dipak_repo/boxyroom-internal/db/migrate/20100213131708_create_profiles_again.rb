class CreateProfilesAgain < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :type
      
      t.references :application

      # personal particulars

      t.boolean :smoker
     
      # photo

      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at

      # identification information

      t.integer :identification_type
      t.string :identification_no
      t.string :country_of_issue
      t.date :expiry_date
      
      t.string :identification_file_name
      t.string :identification_content_type
      t.integer :identification_file_size
      t.datetime :identification_updated_at

      # student profile

      t.string :student_no
      t.integer :income_source
      t.integer :weekly_income

      # employee profile

      t.string :company_name
      t.string :industry
      t.string :position
      t.string :nature_of_employment
      t.date :start_of_employment
      t.date :end_of_employment
      t.integer :gross_annual_salary

      # traveller profile

      t.string :previous_destination
      t.string :next_destination

      # timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
