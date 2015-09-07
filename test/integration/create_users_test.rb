require 'test_helper'

class CreateUsersTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @new_user_params = {
      username:   "user",
      password:   "password",
      license:    "client",
      first_name: "john",
      last_name:  "doe",
    }
    
    @possible_users = [
      @eclient1,
      @student,
      @ustudent,
      @trainer,
      @employee,
      @employer,
      @owner,
    ]
    
    @possible_licenses = [
      "client", 
      "student",
      "unlimited student",
      "CFNS", 
      "employee",
      "employer",
      "owner"
    ]
    
  end

  test "login with invalid information" do
    @eclient1.password = ""
    get login_path
    assert_template 'sessions/new'
    login_as(@eclient1)
    assert_template 'sessions/new'
    assert_not is_logged_in?
  end

  test "login with valid information followed by logout" do
    login_as(@eclient1)
    assert is_logged_in?
    delete logout_path, session: {username: @eclient1.username}
    assert_not is_logged_in?
  end
  
  test "different licenses see the right menu options" do
    @possible_users.each do |u|
      login_as(u)
      assert_select "a", "Home"
      assert_select "a", "Account"
      assert_select "a", "Log out"
      if u.license == "client"
        assert_select "a", text: "Client's Profile", count: 0
      elsif u.license == "client" || !session[:focussed_id].blank?
        assert_select "a", "What Works"
        assert_select "a", "Basic Info"
        assert_select "a", "Measurements"
        assert_select "a", "Body Fat"
        assert_select "a", "Exercise Plan"
        assert_select "a", "Meal Plan"
      elsif u.license != "client" && !session[:focussed_id].blank?
        assert_select "a", "Notes"
        assert_select "a", "Client Profile"
      elsif u.license != "owner" && u.license != "employer"
        assert_select "a", "Clients"
      elsif u.license == "employer"
        assert_select "a", "Clients & Employers"
      elsif u.license == "owner"
        assert_select "a", "Users"
      end
    end
  end
  
  test "client shouldn't be able to create any user" do
    login_as(@eclient1)
    for i in 0...@possible_licenses.length
      @new_user_params[:username] = "user#{i}"
      @new_user_params[:first_name] = "name#{i}"
      cannot_create(@possible_licenses[i])
    end
  end

  test "student should be able to create only 5 clients" do
    login_as(@student)
    for i in 0...(4-@student.clients.length)
      @new_user_params[:username] = "user#{i}"
      @new_user_params[:first_name] = "name#{i}"
      can_create("client")
    end
    for i in 0...@possible_licenses.length
      @new_user_params[:username] = "user#{i}"
      @new_user_params[:first_name] = "name#{i}"
      cannot_create(@possible_licenses[i])
    end
  end

  test "unlimited students should only be able to create clients" do
    login_as(@ustudent)
    uste_test
  end
  
  test "CFNSs should only be able to create clients" do
    login_as(@trainer)
    uste_test
  end
  
  test "employees should only be able to create clients" do
    login_as(@employee)
    uste_test
  end

  test "employers should only be able to create clients (and change
        graduated students into employees)" do
    login_as(@employer)
    can_create("client")
    cannot_create("employee")
    cannot_create("student")
    cannot_create("unlimited student")
    cannot_create("CFNS")
    cannot_create("employer")
    cannot_create("owner")
  end

  test "owner can create any licensed user" do
    login_as(@owner)
    for i in 0...@possible_licenses.length
      @new_user_params[:username] = "user#{i}"
      @new_user_params[:first_name] = "name#{i}"
      can_create(@possible_licenses[i])
    end
  end

	test 'users name should be capitalized upon creation' do
    login_as(@owner)
    post users_path, user: @new_user_params
    @new_user = User.find_by(username: @new_user_params[:username])
    to_capitalize = [:first_name, :last_name]
    to_capitalize.each do |field|
      field_string = field.to_s
      assert_equal  @new_user.send(field_string),
                    @new_user_params[field].capitalize
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
  
  def can_create(license)
    @new_user_params[:license] = license
    assert_difference 'User.count', 1 do
      post users_path, user: @new_user_params
      puts flash[:danger] if !flash[:danger].nil?
    end
  end

  def cannot_create(license)
    @new_user_params[:license] = license
    assert_difference 'User.count', 0 do
      post users_path, user: @new_user_params
    end
  end
  
  def uste_test
    can_create(@possible_licenses[0])
    for i in 1...@possible_licenses.length
      @new_user_params[:username] = "user#{i}"
      @new_user_params[:first_name] = "name#{i}"
      cannot_create(@possible_licenses[i])
    end
  end
end