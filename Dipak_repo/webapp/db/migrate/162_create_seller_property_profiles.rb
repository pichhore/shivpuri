class CreateSellerPropertyProfiles < ActiveRecord::Migration
  def self.up
    exists = SellerPropertyProfile.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table seller_property_profiles..."
        create_table :seller_property_profiles, :id => false do |t|

          t.column :id,                        :string, :limit => 36, :null => false
          t.column :seller_profile_id,         :string, :limit => 36, :null => false, :references => :seller_profiles
          t.column :is_owner,                  :boolean, :default => true
          t.column :zip_code,                  :string
          t.column :property_type,             :string
          t.column :property_address,          :string
          t.column :beds,                      :integer
          t.column :baths,                     :integer
          t.column :square_feet,               :integer
          t.column :price,                     :integer
          t.column :units,                     :integer
          t.column :acres,                     :integer
          t.column :privacy,                   :string, :default => "public"
          t.column :description,               :string
          t.column :has_description,           :boolean
          t.column :has_features,              :boolean
          t.column :property_type_sort_order,  :boolean
          t.column :has_profile_image,         :boolean
          t.column :profile_type_id,           :string
          t.column :min_mon_pay,               :integer
          t.column :min_dow_pay,               :integer
          t.column :status,                    :string, :default => "active"
          t.column :contract_end_date,         :date
          t.column :profile_created_at,        :datetime
          t.column :deal_terms,                :text
          t.column :video_tour,                :string
          t.column :embed_video,               :text
          t.column :notification_email,        :string
          t.column :notification_phone,        :string
          t.column :garage,                    :string
          t.column :stories,                   :string
          t.column :neighborhood,              :string
          t.column :trees,                     :string
          t.column :natural_gas,               :string
          t.column :electricity,               :string
          t.column :sewer,                     :string
          t.column :water,                     :string
          t.column :pool,                      :string
          t.column :livingrooms,               :string
          t.column :fencing,                   :string
          t.column :school_elementary,         :string
          t.column :school_middle,             :string
          t.column :school_high,               :string
          t.column :breakfast_area,            :string
          t.column :formal_dining,             :string
          t.column :pool,                      :string
          t.column :waterfront,                :string
          t.column :condo_community_name,      :string
          t.column :feature_tags,              :string
          t.column :total_actual_rent,         :string
          t.column :county,                    :string
          t.column :barn,                      :string
          t.column :manufactured_home,         :string
          t.column :house,                     :string

          t.timestamps
        end
        puts "Setting primary key"
        execute "ALTER TABLE seller_property_profiles ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SellerPropertyProfile.table_exists? rescue false
      if exists
        drop_table :seller_property_profiles
      end
  end
end
