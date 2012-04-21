class CreateProfileImages < ActiveRecord::Migration
  def self.up
    exists = ProfileImage.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table profile_images..."
        create_table "profile_images", :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :profile_id, :string, :limit => 36, :null => false, :references => :profiles
          t.column :created_at, :datetime

          # acts_as_attachment fields
          t.column "content_type", :string
          t.column "filename", :string
          t.column "size", :integer
          #t.column "db_file_id", :integer # only for db files (optional)

          # only for thumbnails
          t.column "parent_id", :string, :limit => 36, :references => nil
          t.column "thumbnail", :string

          # only for images (optional)
          t.column "width", :integer
          t.column "height", :integer
        end

        puts "Setting primary key"
        execute "ALTER TABLE profile_images ADD PRIMARY KEY (id)"

      end
    end

  end

  def self.down
    exists = ProfileImage.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table profile_images..."
        drop_table :profile_images
      end
    end
  end
end
