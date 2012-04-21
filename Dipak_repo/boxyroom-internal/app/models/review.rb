class Review < ActiveRecord::Base
  belongs_to :application
  belongs_to :property
  has_many :reivew_property_pictures, :dependent => :destroy

  validates_uniqueness_of :property_id, :application_id

  accepts_nested_attributes_for :reivew_property_pictures, :allow_destroy => true

#   validates_date :rental_to, :before => Time.now 

  validate :renatal_from_validation
  validate :renatal_from_less_than_rental_to

  def renatal_from_validation
       errors.add_to_base( "Period of Rental From must be the expected arrival date of tenant") if
       rental_from < self.application.expected_arrival
  end

  def renatal_from_less_than_rental_to
       errors.add_to_base( "Period of Rental From must be less than period of rental to") if
       rental_from >= rental_to
  end


end
