require "validatable"
class SupportEmail
    include Validatable
    FIELDS = [:to_email, :body, :subject]
    validates_presence_of :to_email, :message => "can't be blank"
    validates_presence_of :body, :message => "can't be blank"
    validates_presence_of :subject, :message => "can't be blank"
    validates_format_of :to_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :message => "Invalid email address."
    attr_accessor :to_email, :body, :subject
end