class AddAttributesToSyndicateProperties < ActiveRecord::Migration
  def self.up
    add_column :syndicate_properties, :title, :string
    add_column :syndicate_properties, :business_phone, :string
    add_column :syndicate_properties, :business_email, :string
    add_column :syndicate_properties, :image_link, :string
    add_column :syndicate_properties, :property_link, :string
  end

  def self.down
    remove_column :syndicate_properties, :property_link
    remove_column :syndicate_properties, :image_link
    remove_column :syndicate_properties, :business_email
    remove_column :syndicate_properties, :business_phone
    remove_column :syndicate_properties, :title
  end
end
