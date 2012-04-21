class SellerFinancialInfo < ActiveRecord::Base
  uses_guid
  belongs_to :seller_property_profile
  FINANCIAL_LOAN_NUMBER = {"loan_one" => "loan_one", "loan_two" => "loan_two" }

  def self.get_seller_financial_information(seller_property, loan_number)
    seller_financial_info = seller_property.seller_financial_infos
    return seller_property.seller_financial_infos.new() if seller_financial_info.blank?
    return seller_property.seller_financial_infos.find(:first, :conditions => ["financial_loan_number=?",loan_number])
  end

end
