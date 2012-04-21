class Zcta < ActiveRecord::Base
  belongs_to :zip
  has_many :latlongs, :order => "seq"
end
