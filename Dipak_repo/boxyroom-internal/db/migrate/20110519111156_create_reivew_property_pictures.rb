class CreateReivewPropertyPictures < ActiveRecord::Migration
  def self.up
    create_table :reivew_property_pictures do |t|
      t.references :review
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :reivew_property_pictures
  end
end
