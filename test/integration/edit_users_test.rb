require 'test_helper'

class EditUsersTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @target_user = users(:tclient)
    
    @possible_users = [
      @eclient1, 
      @student,
      @ustudent,
      @trainer, 
      @employee,
      @employer,
      @owner
    ]
  end
  
  test "users can edit their own info" do
    @possible_users.each do |u|
      login_as(u)
      get edit_user_path(u.id)
      assert_response :success
      logout_as(u)
    end
  end

  test "client can't edit anyone else" do
    login_as(@target_user)
    @possible_users.each do |u|
      get edit_user_path(u.id)
      assert !flash.empty?
      assert_redirected_to :root
    end    
  end

  test "student, ustudent, trainer, employer can edit their own clients" do
    test_array = [@student, @ustudent, @trainer, @employer]
    test_array.each do |u|
      login_as(u)
      get edit_user_path(u.clients.first.id)
      assert_response :success
      logout_as(u)
    end
  end
  
  test "employee can edit employer's client" do
    login_as(@employee)
    get edit_user_path(@employer.clients.first.id)
    assert_response :success
  end
  
  test "no one else can edit another user's client" do
    login_as(@student)
    get edit_user_path(@trainer.clients.first.id)
    assert !flash.empty?
    assert_redirected_to :root
    logout_as(@student)
    test_array = [@ustudent, @trainer, @employer]
    test_array.each do |u|
      login_as(u)
      get edit_user_path(@student.clients.first.id)
      assert !flash.empty?
      assert_redirected_to :root
      logout_as(u)
    end
  end
  
  test "employer can edit employee" do
    login_as(@employer)
    get edit_user_path(@employee.id)
    assert_response :success
  end
  
  test "owner can edit any user" do
    login_as(@owner)
    @possible_users.each do |target|
      get edit_user_path(target.id)
      assert_response :success
    end
  end
  
  test "only self and owner can edit these" do
    test_array = [  
      @student,
      @ustudent,
      @trainer, 
      @employer,
      @owner
    ]
    @possible_users.each do |u|
      login_as(u)
      test_array.each do |target|
        get edit_user_path(target.id)
        if u.license == "owner" || u == target
          assert_response :success
        else
          assert_redirected_to :root
        end
      end
    end
  end

  def login_as(user)
    post_via_redirect login_path, session: { 
      username: user.username,
      password: user.password
    }
    @current_user = user
    @license = user.license
  end
  
  def logout_as(user)
  	user.update_attribute("logged_in", false)
  	session.delete(:user_id)
  	@current_user = nil
  end

end