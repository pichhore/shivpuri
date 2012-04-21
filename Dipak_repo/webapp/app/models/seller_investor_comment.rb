# class SellerInvestorComment < ActiveRecord::Base
#     validates_presence_of     :name
#     validates_presence_of     :email
# end


require "validatable"
class SellerInvestorComment
    include Validatable
    FIELDS = [:email, :name, :comment]
    validates_presence_of:name, :email, :message => "can't be blank"
    validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :message => "is not a valid email address."

  create_attrs FIELDS
end