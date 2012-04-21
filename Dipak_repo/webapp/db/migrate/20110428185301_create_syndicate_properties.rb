class CreateSyndicateProperties < ActiveRecord::Migration
  def self.up
    create_table :syndicate_properties do |t|
      t.string :profile_id, :limit => 36, :null => false, :references => :profiles
      t.date :contract_end_date
      t.string :deal_terms
      t.string :price
      t.string :embed_video
      t.integer :min_dow_pay
      t.float :acres
      t.string :zip_code
      t.string :water
      t.string :property_address
      t.string :school_high
      t.string :school_middle
      t.string :feature_tags
      t.string :units
      t.float :baths
      t.string :school_elementary
      t.string :county
      t.integer :total_actual_rent
      t.string :property_type
      t.string :sewer
      t.string :neighborhood
      t.integer :square_feet
      t.integer :beds
      t.string :condo_community_name
      t.integer :livingrooms
      t.string :video_tour
      t.string :description
      t.integer :min_mon_pay
      t.string :garage
      t.integer :stories
      t.string :pool
      t.string :waterfront
      t.string :manufactured_home
      t.string :house
      t.string :barn
      t.string :fencing
      t.string :natural_gas      
      t.string :electricity

      t.timestamps
    end
  end

  def self.down
    drop_table :syndicate_properties
  end
end
