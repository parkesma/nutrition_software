require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    @student = users(:student)
    @trainer = users(:trainer)
    @expired = users(:expired)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "valid login" do
    login(@student)
    assert is_logged_in?
  end
    
  test "invalid login" do
    assert !is_logged_in?
    @student.password = "invalid"
    login(@student)
    assert !is_logged_in?
  end
  
  test "should redirect on second simultaneous login, but permit new login" do
    assert !is_logged_in?
    login(@student)
    assert is_logged_in?
    assert flash.empty?
    login(@student)
    assert_not flash.empty?
  end
  
  test "should redirect on expired account" do
    login(@expired)
    assert !is_logged_in?
    assert_not flash.empty?
  end
  
  def login(user)
    post :create, session: {
      username: user.username,
      password: user.password
    }    
  end


end