class CreateProfileSellerLeadMappings < ActiveRecord::Migration
  def self.up
     exists = CreateProfileSellerLeadMapping.table_exists? rescue false
     if !exists
      transaction do 
        create_table :profile_seller_lead_mappings do |t|
          t.string :profile_id, :limit => 36, :null => false, :references => :profiles
          t.string :seller_profile_id, :limit => 36, :null => false, :references => :seller_profiles
          t.timestamps
        end
      end
    end 	
  end

  def self.down
    drop_table :profile_seller_lead_mappings
  end
end
