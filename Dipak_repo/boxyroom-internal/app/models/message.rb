class Message < ActiveRecord::Base
  include AASM
  belongs_to :thread, :class_name => "MessageThread", :foreign_key => "thread_id"
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"

  validates_presence_of :body, :message=>"Enter your message."

  def reply_to
    address = "reply_#{thread.code}@boxyroom.com"
    if RAILS_ENV == "development"
      return "dev_#{address}"
    end
    address
  end


  aasm_column :status
  aasm_initial_state :unread

  aasm_state :unread
  aasm_state :read
  
  aasm_event :read_m do
    transitions :to => :read, :from => [:unread]
  end

  named_scope :messages_to_me, lambda { |status| {:conditions => ["status = ?", status]} }

end
