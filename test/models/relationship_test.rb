require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  def setup
    @relationship = Relationship.new(sup_id: 1, sub_id: 2)
  end
  
  test "should be valid" do
    assert @relationship.valid?
  end
  
  test "should require a sup_id" do
    @relationship.sup_id = nil
    assert_not @relationship.valid?
  end
  
  test "should require a sub_id" do
    @relationship.sub_id = nil
    assert_not @relationship.valid?
  end
end
