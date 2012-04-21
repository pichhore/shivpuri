class InvestorMessage < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "sender_id"
  has_many :recievers,:through=>:investor_message_recipients,:class_name => "User", :foreign_key => "reciever_id"
  has_many :investor_message_recipients,:dependent => :destroy
  after_create :after_create_reward_badge
  cattr_reader :per_page
   @@per_page = 10

  
    def after_create_reward_badge
      user = User.find_by_id(self.sender_id)
      #Award a Badge to user when sent message investor to investor
      BadgeUser.reward_badge_for_the_user(user) unless user.blank?
    end
    
    def self.no_of_investor_messages_sent(user_id)
      return self.count_by_sql("select count(*) from investor_messages where sender_id='#{user_id}'")
    end
   
end
