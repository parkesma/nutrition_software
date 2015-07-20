require 'test_helper'

class UserTest < ActiveSupport::TestCase
    
  def setup
    @user = User.new(username: "test_user", password: "password")
  end
  
  test "name should be present" do
    assert @user.valid?
    @user.username = ""
    assert !@user.valid?
  end
  
  test "password should be present" do
    assert @user.valid?
    @user.password = ""
    assert !@user.valid?
  end 

  test "should find employer's clients in subs" do
    assert_equal users(:employer).clients.length, 2
    assert_equal users(:employee).clients.length, 2
  end
  
  test "should find employer's employees in subs" do
    employer = users(:employer)
    assert_equal employer.employees.length, 1
  end
  
end