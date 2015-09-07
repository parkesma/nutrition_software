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
  
  test "users can edit their own account profile" do
    @possible_users.each do |u|
      login_as(u)
      get edit_user_path(u.id)
      patch user_path(u), user: {first_name: "New #{u.id}"}
      assert_equal u.reload.first_name, "New #{u.id}"
      logout_as(u)
    end
  end

  test "client can't edit anyone else's account profile" do
    login_as(@target_user)
    @possible_users.each do |u|
      get edit_user_path(u.id)
      patch user_path(u), user: {first_name: "New #{u.id}"}
      assert u.reload.first_name != "New #{u.id}"
      assert !flash.empty?
      assert_redirected_to :root
    end    
  end

  test "student, ustudent, CFNS, employer can edit their own 
        clients" do
    test_array = [@student, @ustudent, @trainer, @employer]
    test_array.each do |u|
      login_as(u)
      get edit_user_path(u.clients.first)
      patch user_path(u.clients.first), user: {first_name: 
        "New #{u.id}"}
      assert_equal u.clients.first.reload.first_name, 
        "New #{u.id}"
      logout_as(u)
    end
  end
  
  test "employee can edit employer's client" do
    login_as(@employee)
    get edit_user_path(@employer.clients.first)
    patch user_path(@employer.clients.first), 
      user: {first_name: "New #{
      @employer.clients.first.id}"}
    assert_equal @employer.clients.first.reload.first_name, 
      "New #{@employer.clients.first.id}"
  end
  
  test "no one else can edit another user's client" do
    login_as(@student)
    get edit_user_path(@trainer.clients.first.id)
    patch user_path(@trainer.clients.first), 
        user: {first_name: "New #{
        @trainer.clients.first.id}"}
    assert @trainer.clients.first.reload.first_name != 
      "New #{@trainer.clients.first.id}"
    assert !flash.empty?
    assert_redirected_to :root
    logout_as(@student)
    
    test_array = [@ustudent, @trainer, @employer]
    test_array.each do |u|
      login_as(u)
      get edit_user_path(@student.clients.first)
      patch user_path(@student.clients.first), 
        user: {first_name: "New #{
        @student.clients.first.id}"}
      assert @student.clients.first.reload.first_name != 
        "New #{@student.clients.first.id}"
      assert !flash.empty?
      assert_redirected_to :root
      logout_as(u)
    end
  end
  
  test "employer can edit employee" do
    login_as(@employer)
    get edit_user_path(@employee)
    patch user_path(@employee), user: {first_name:
      "New #{@employee.id}"}
    assert_equal @employee.reload.first_name,
      "New #{@employee.id}"
  end
  
  test "owner can edit any user" do
    login_as(@owner)
    @possible_users.each do |u|
      get edit_user_path(u)
      patch user_path(u), user: {first_name:
        "New #{u.id}"}
      assert_equal u.reload.first_name,
        "New #{u.id}"
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
        patch user_path(target), user: {first_name:
          "New #{u.id} #{target.id}"}
        if u.license == "owner" || u == target
          assert_equal target.reload.first_name,
            "New #{u.id} #{target.id}"
          assert_redirected_to user_path(target)
        else
          assert target.reload.first_name != 
            "New #{u.id} #{target.id}"
        end
      end
    end
  end
  
  test 'users info should be capitalized upon update' do
    login_as(@owner)
    @user = User.find_by(username: @eclient1[:username])
    patch user_path(@user), user: {
      first_name: "lowercase",
      last_name: "lowercase",
      home_city: "lowercase",
      work_city: "lowercase",
      company: "lowercase"
    }

    assert_equal  @user.reload.first_name, "Lowercase"
    assert_equal  @user.last_name, "Lowercase"
    assert_equal  @user.home_city, "Lowercase"
    assert_equal  @user.work_city, "Lowercase"
    assert_equal  @user.company, "Lowercase"
    
  end
  
  test "client shouldn't be able to edit his own basic info" do
    login_as(@eclient1)
    get basic_info_path
    patch basic_info_path(@eclient1), user: {
      present_weight: 100
    }
    assert !flash[:danger].blank?
    assert @eclient1.reload.present_weight != 100
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