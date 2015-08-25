require 'test_helper'

class DisplayUsersTest < ActionDispatch::IntegrationTest
  
  def setup
    @owner            = users(:owner)
    
    @employer         = users(:employer)
    @employee         = users(:employee)
    @eclient1         = users(:eclient1)
    @eclient2         = users(:eclient2)
    
    @student          = users(:student)
    @sclient1         = users(:sclient1)
    @sclient2         = users(:sclient2)
    
    @ustudent         = users(:ustudent)
    @uclient          = users(:uclient)
    
    @trainer          = users(:trainer)
    @tclient          = users(:tclient)

    @orphan_client    = users(:orphan_client)
    @orphan_employee  = users(:orphan_employee)

  end
  
  test "owner should see all users" do
    login_as(@owner)
    all = User.all
    count_links(all)
  end
  
  test "employer should see only employees and clients" do
    login_as(@employer)
    subs = [@employee, @eclient1, @eclient2]
    count_links(subs)
  end
  
  test "employee should see only employer's clients" do
    login_as(@employee)
    subs = [@eclient1, @eclient2]
    count_links(subs)
  end

  test "student should see only his own clients" do
    login_as(@student)
    subs = [@sclient1, @sclient2]
    count_links(subs)
  end
  
  test "ustudent should see only his own clients" do
    login_as(@ustudent)
    subs = [@uclient]
    count_links(subs)
  end
  
  test "trainer should see only his own clients" do
    login_as(@trainer)
    subs = [@tclient]
    count_links(subs)
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
  
  def count_links(array)
    array.each do |u|
      assert_select 'a[href=?]', "/users/#{u.id}/edit", text: "edit"
      assert_select 'a[href=?]', "/users/#{u.id}",      text: 'delete', method: :delete
    end
    assert_select 'a', text: 'delete', count: array.length
  end
  
end
