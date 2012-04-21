class CreatePropertyDocs < ActiveRecord::Migration
  def self.up
    create_table :property_docs do |t|
      t.references :property
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :property_docs
  end
end
