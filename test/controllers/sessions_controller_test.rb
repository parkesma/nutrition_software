require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    @student = users(:student)
    @trainer = users(:trainer)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "valid login" do
    login_as(@student)
    assert is_logged_in?
  end
    
  test "login invalid" do
    assert !is_logged_in?
    assert_nil @current_user
    assert_nil @license
    @student.password = "invalid"
    login_as(@student)
    assert !is_logged_in?
  end
  
  test "should redirect on second simultaneous login" do
    assert !is_logged_in?
    login_as(@student)
    assert is_logged_in?
    login_as(@student)
    assert_not flash.empty?
  end

end
