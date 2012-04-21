class CreateBadgeImages < ActiveRecord::Migration
  def self.up
    create_table :badge_images do |t|
      t.column "badge_id", :integer, :null => false
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer, :reference => nil 
      t.column "thumbnail", :string
      
      # required for images only
      t.column "width", :integer  
      t.column "height", :integer
      
    end

    # only for db-based files
    # create_table :db_files, :force => true do |t|
    #      t.column :data, :binary
    # end
  end

  def self.down
    drop_table :badge_images
  end
end
