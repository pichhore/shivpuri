require "validatable"
class SentReport
    include Validatable
    FIELDS = [:email]
    validates_presence_of :email, :message => "can't be blank"
    validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :message => "Invalid email address."
    attr_accessor :email
end