require 'test_helper'

class NoteTest < ActiveSupport::TestCase

  def setup
    @client = users(:eclient1)
    @note1 = notes(:note1)
    @note2 = notes(:note2)
    @employer = users(:employer)
    @employee = users(:employee)
  end
  
  test "note.author should return note's author" do
    assert_equal @note1.author, @employer
    assert_equal @note2.author, @employee
  end
  
end
