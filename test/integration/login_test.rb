require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest

  def setup
    @student = users(:student)
    @ustudent = users(:ustudent)
  end
  
  test "students logging in for the first time should be redirected to their edit screen" do
    @student.update(login_count: 0)
    login_as(@student)
    assert_redirected_to edit_user_path(@student)
    assert_equal @student.reload.login_count, 1
    
    @ustudent.update(login_count: 0)
    login_as(@ustudent)
    assert_redirected_to edit_user_path(@ustudent)
    assert_equal @ustudent.reload.login_count, 1
  end
  
  test "students loggin in subsequent times should be redirected to users inde" do
    @student.update(login_count: 2)
    login_as(@student)
    assert_redirected_to users_path(@student.id)
    
    @ustudent.update(login_count: 2)
    login_as(@ustudent)
    assert_redirected_to users_path(@ustudent.id)
  end
  
  def login_as(user)
    post login_path, session: { 
      username: user.username,
      password: user.password
    }
  end

end
