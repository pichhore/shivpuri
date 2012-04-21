class CreateFeaturedProfiles < ActiveRecord::Migration
  def self.up
    exists = FeaturedProfile.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table featured_profiles..."
        create_table :featured_profiles, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_type, :string
          t.column :profile_id, :string, :limit => 36, :references=>:profiles
          t.column :created_at, :datetime, :null => false
        end

        puts "Setting primary key"
        execute "ALTER TABLE featured_profiles ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = FeaturedProfile.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table featured_profiles..."
        drop_table :featured_profiles
      end
    end
  end
end
