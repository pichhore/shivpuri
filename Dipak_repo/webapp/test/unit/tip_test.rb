require File.dirname(__FILE__) + '/../test_helper'

class TipTest < Test::Unit::TestCase
  fixtures :tips

  def test_next_tip_with_index_should_return_only_tip_available
    tip,index = Tip.find_next_tip_with_index("buyer_dashboard")
    assert_equal 0, index
    assert_not_nil tip
    assert_equal tips(:one).id, tip.id
  end

  def test_next_tip_with_index_should_return_first_tip
    tip,index = Tip.find_next_tip_with_index("owner_dashboard")
    assert_equal 0, index
    assert_not_nil tip
    assert_equal tips(:two).id, tip.id
  end

  def test_next_tip_with_index_should_return_second_tip
    tip,index = Tip.find_next_tip_with_index("owner_dashboard",0)
    assert_equal 1, index
    assert_not_nil tip
    assert_equal tips(:three).id, tip.id
  end

  def test_next_tip_with_index_should_return_first_tip_again
    tip,index = Tip.find_next_tip_with_index("owner_dashboard",1)
    assert_equal 0, index
    assert_not_nil tip
    assert_equal tips(:two).id, tip.id
  end

  def test_next_tip_with_index_should_return_first_tip_if_index_greater_available_tips
    tip,index = Tip.find_next_tip_with_index("owner_dashboard",10000)
    assert_equal 0, index
    assert_not_nil tip
    assert_equal tips(:two).id, tip.id
  end
end
