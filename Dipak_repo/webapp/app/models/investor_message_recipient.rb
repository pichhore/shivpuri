class InvestorMessageRecipient < ActiveRecord::Base
  belongs_to :investor_message
  belongs_to :reciever, :class_name => "User", :foreign_key => "reciever_id"
  cattr_reader :per_page
   @@per_page = 10
end
