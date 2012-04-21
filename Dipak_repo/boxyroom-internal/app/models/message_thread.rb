class MessageThread < ActiveRecord::Base
  has_many :messages, :foreign_key => "thread_id"
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :participant, :class_name => "User", :foreign_key => "participant_id"
  belongs_to :property

  before_validation_on_create :generate_code

  private

  def generate_code
    self.code = ActiveSupport::SecureRandom.hex
  end
end
