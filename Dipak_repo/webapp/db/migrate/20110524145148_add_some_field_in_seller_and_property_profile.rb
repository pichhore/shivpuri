class AddSomeFieldInSellerAndPropertyProfile < ActiveRecord::Migration
  def self.up
    add_column        :seller_profiles,            :price_want,             :string
    add_column        :seller_property_profiles,   :last_list_price,        :string
    add_column        :seller_property_profiles,   :tax_appraised_value,    :string
    add_column        :seller_property_profiles,   :price_bottom,           :string
    add_column        :seller_property_profiles,   :legal_description,      :string
    add_column        :seller_financial_infos,     :price_need,             :string
  end

  def self.down
    remove_column        :seller_profiles,            :price_want
    remove_column        :seller_property_profiles,   :last_list_price
    remove_column        :seller_property_profiles,   :tax_appraised_value
    remove_column        :seller_property_profiles,   :price_bottom
    remove_column        :seller_property_profiles,   :legal_description
    remove_column        :seller_financial_infos,     :price_need
  end
end
