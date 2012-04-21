class InvestmentType < ActiveRecord::Base
  has_many :profiles, :dependent => :destroy
end