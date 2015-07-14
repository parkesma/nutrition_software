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

end