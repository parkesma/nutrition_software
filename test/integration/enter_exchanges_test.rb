require 'test_helper'

class EnterExchangesTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @owners = exchanges(:owners)
    @employers = exchanges(:employers)
    @others = exchanges(:others)
    
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
  
  test "client can't index, create, update, or delete any" do
    login_as(@eclient1)
    cannot_index(@owners)
    cannot_create
    cannot_update(@owners)
    cannot_delete(@owners)
  end

  test "!client && !owner can index but not update or delete owner's" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "owner"
        login_as(u)
        can_index(@owners)
        cannot_update(@owners)
        cannot_delete(@owners)
      end
    end
  end
  
  test "Owner can index, create, update, and delete all" do
    login_as(@owner)
    can_index(@employers)
    can_create
    can_update(@employers)
    can_delete(@employers)
  end
  
  test "Employee can index, create, and edit, but not delete employer's" do
    login_as(@employee)
    can_index(@employers)
    can_create
    employees_exchange = Exchange.find_by(name: "new exchange")
    assert_equal employees_exchange.user, @employer
    can_update(@employers)
    cannot_delete(@employers)
  end
  
  test "!client & !employee can index, create, edit, and delete their own, but not
  another user's" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "employee" && u.license != "owner"
        login_as(u)
        can_create
        my_exchange = Exchange.find_by(user_id: u.id)
        can_index(my_exchange)
        can_update(my_exchange)
        can_delete(my_exchange)
        
        cannot_index(@others)
        cannot_update(@others)
        cannot_delete(@others)
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
  
  def focus_on(user)
    get user_path(user.id)
  end
  
  def cannot_index(exchange)
    get exchanges_path
    assert_no_match exchange.name.to_s, 
      response.body
  end
  
  def can_index(exchange)
    get exchanges_path
    assert_match exchange.name.to_s,
      response.body
  end
      
  def cannot_create
    assert_difference 'Exchange.count', 0 do
      post exchanges_path, exchange: {name: "new exchange"}
    end
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'Exchange.count', 1 do
      post exchanges_path, exchange: {name: "new exchange"}
    end
  end
    
  def cannot_update(exchange)
    patch exchange_path(exchange), 
      exchange: {name: "changed exchange"}
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def can_update(exchange)
    assert exchange.name != "changed exchange"
    patch exchange_path(exchange), 
      exchange: {name: "changed exchange"}
    assert exchange.reload.name == "changed exchange"
  end
  
  def cannot_delete(exchange)
    assert_difference 'Exchange.count', 0 do
      delete exchange_path(exchange)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(exchange)
    assert_difference 'Exchange.count', -1 do
      delete exchange_path(exchange)
    end
  end

end