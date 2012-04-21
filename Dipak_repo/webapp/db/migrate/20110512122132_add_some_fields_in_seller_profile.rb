class AddSomeFieldsInSellerProfile < ActiveRecord::Migration
  def self.up
    add_column :seller_profiles,            :date_created,                  :string
    add_column :seller_profiles,            :need_to_sell_in,               :string
    add_column :seller_profiles,            :seller_motivation,             :text
    add_column :seller_profiles,            :bankruptcy,                    :string
    add_column :seller_profiles,            :type,                          :string
    add_column :seller_profiles,            :home_included,                 :string
    add_column :seller_profiles,            :bankruptcy_expiration,         :datetime
    add_column :seller_profiles,            :divorce,                       :string
    add_column :seller_profiles,            :relation_with_spouse,          :text
    add_column :seller_profiles,            :additional_contact_notes,      :text
    add_column :seller_profiles,            :source,                        :string
    add_column :seller_property_profiles,   :additional_property_detail,    :text
  end

  def self.down
    remove_column :seller_profiles,            :date_created
    remove_column :seller_profiles,            :need_to_sell_in
    remove_column :seller_profiles,            :seller_motivation
    remove_column :seller_profiles,            :bankruptcy
    remove_column :seller_profiles,            :type
    remove_column :seller_profiles,            :home_included
    remove_column :seller_profiles,            :bankruptcy_expiration
    remove_column :seller_profiles,            :divorce
    remove_column :seller_profiles,            :relation_with_spouse
    remove_column :seller_profiles,            :additional_contact_notes
    remove_column :seller_profiles,            :source
    remove_column :seller_property_profiles,   :additional_property_detail
  end
end