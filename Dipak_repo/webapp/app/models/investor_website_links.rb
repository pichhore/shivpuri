class InvestorWebsiteLinks < ActiveRecord::Base
 belongs_to :investor_website, :dependent => :destroy  
end
