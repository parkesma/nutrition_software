require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "login as student" do
    user = users(:student)
    login_as(user)
    assert is_logged_in?
  end
    
  test "login invalid" do
    assert !is_logged_in?
    assert_nil @current_user
    assert_nil @license
  end

end
