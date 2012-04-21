require File.dirname(__FILE__) + '/../test_helper'

class ProfileMessageRecipientTest < Test::Unit::TestCase

  def test_find_for
    @profile = profiles(:buyer2)
    @profile_message_recipients, @count = ProfileMessageRecipient.find_for(@profile)
    assert_equal 2, @profile_message_recipients.length
    assert_equal 'message2_recipient1', @profile_message_recipients[0].id
    assert_equal 'message2_recipient2', @profile_message_recipients[1].id
  end

  def test_profile_delete_as_paranoid_should_delete_profile_message_recipients
    @profile = profiles(:buyer2)
    assert_not_nil @profile

    assert_equal 2, @profile.profile_message_recipients_from.length
    assert_equal 2, @profile.profile_message_recipients_to.length
    @profile.destroy

    @not_deleted = ProfileMessageRecipient.find(:all, :conditions =>["from_profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileMessageRecipient.find_with_deleted(:all, :conditions =>["from_profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 2, @deleted.length

    @not_deleted = ProfileMessageRecipient.find(:all, :conditions =>["to_profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileMessageRecipient.find_with_deleted(:all, :conditions =>["to_profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 2, @deleted.length
  end
end
