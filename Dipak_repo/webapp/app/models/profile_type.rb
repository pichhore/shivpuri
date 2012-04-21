class ProfileType < ActiveRecord::Base
  uses_guid
  uses_permalink :name

  def self.BUYER
    return find_by_permalink('buyer')
  end

  def self.OWNER
    return find_by_permalink('owner')
  end

  def self.BUYER_AGENT
    return find_by_permalink('buyer_agent')
  end

  def self.SELLER_AGENT
    return find_by_permalink('seller_agent')
  end

  def self.SERVICE_PROVIDER
    return find_by_permalink('service_provider')
  end

  def self.get_guid(permalink)
    # don't really like to hard-code these, but they're hard-coded in the migrations and it can eliminate a join
    return 'ce5c2320-4131-11dc-b431-009096fa4c28' if permalink == 'buyer'
    return 'ce5c2320-4131-11dc-b432-009096fa4c28' if permalink == 'owner'
    return 'ce5c2320-4131-11dc-b433-009096fa4c28' if permalink == 'buyer_agent'
    return 'ce5c2320-4131-11dc-b434-009096fa4c28' if permalink == 'seller_agent'
    return 'ce5c2320-4131-11dc-b435-009096fa4c28' if permalink == 'service_provider'
    return nil
  end
  
  def name_string
    return "Individual" if self.buyer?
    return "FSBO" if self.owner?
    return "Buyers Agent" if self.buyer_agent?
    return "Agent" if self.seller_agent?
    return "Service Provider" if self.service_provider?
    return "N/A"
  end

  def type_string
    return "Buyer" if self.buyer?
    return "Property" if self.owner?
    return "N/A"
  end

  def opposite_type_name_string
    return "Buyer" if self.owner?
    return "Owner" if self.buyer?
    return "Buyer Rep" if self.seller_agent?
    return "Seller Rep" if self.buyer_agent?
    return "N/A"
  end

  def display_singular_got_name_string
    return "buyer" if self.owner? or self.seller_agent?
    return "property" if self.buyer? or self.buyer_agent?
    return "N/A"
  end

  def display_plural_got_name_string
    return "buyers" if self.owner? or self.seller_agent?
    return "properties" if self.buyer? or self.buyer_agent?
    return "N/A"
  end

  def buyer?
    return self.permalink == 'buyer'
  end

  def owner?
    return self.permalink == 'owner'
  end

  def buyer_agent?
    return self.permalink == 'buyer_agent'
  end

  def seller_agent?
    return self.permalink == 'seller_agent'
  end

  def service_provider?
    return self.permalink == 'service_provider'
  end

  def permalink_to_page
    return self.permalink.sub("-","_")
  end
  
  def permalink_to_generic_page
    return self.permalink.sub("seller_agent", "owner").sub("buyer_agent","buyer")
  end
end
