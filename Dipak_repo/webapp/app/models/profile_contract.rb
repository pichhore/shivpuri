class ProfileContract < ActiveRecord::Base
  belongs_to :contract_buyer_type
  belongs_to :contract_seller_type
  belongs_to :profile
  belongs_to :contract_my_buyer, :class_name => "Profile" ,:foreign_key => 'my_buyer'
   validates_presence_of :contract_buyer_type_id
    validates_presence_of :contract_seller_type_id
  validates_presence_of :seller_write_in, :if => :is_seller_write_in
   validates_presence_of :buyer_write_in, :if => :is_buyer_write_in
   validates_presence_of :my_buyer, :if => :is_buyer_my_buyer

  def is_buyer_write_in
    unless contract_buyer_type_id.blank?
      buyer = ContractBuyerType.find(contract_buyer_type_id)
      return true if !buyer.blank? and buyer.code == "WI"
    end
  end

  def is_buyer_my_buyer
    unless contract_buyer_type_id.blank?
      buyer = ContractBuyerType.find(contract_buyer_type_id)
      return true if !buyer.blank? and buyer.code == "MB"
    end
  end

  def is_seller_write_in
    unless contract_seller_type_id.blank?
      seller = ContractSellerType.find(contract_seller_type_id)
      return true if !seller.blank? and seller.code == "WI"
    end
  end

 
end
