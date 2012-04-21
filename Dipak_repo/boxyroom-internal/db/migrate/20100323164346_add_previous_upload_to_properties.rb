class AddPreviousUploadToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :previous_upload, :string
  end

  def self.down
    remove_column :properties, :previous_upload
  end
end
