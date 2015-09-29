require 'test_helper'

class EnterSubExchangesTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @owners = sub_exchanges(:owners)
    @employers = sub_exchanges(:employers)
    @others = sub_exchanges(:others)
    
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
    employees_sub_exchange = SubExchange.find_by(name: "New Sub Exchange")
    assert_equal employees_sub_exchange.user, @employer
    can_update(@employers)
    cannot_delete(@employers)
  end
  
  test "!client & !employee can index, create, edit, and delete their own, but not
  another user's" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "employee" && u.license != "owner"
        login_as(u)
        can_create
        my_sub_exchange = SubExchange.find_by(user_id: u.id)
        can_index(my_sub_exchange)
        can_update(my_sub_exchange)
        can_delete(my_sub_exchange)
        
        cannot_index(@others)
        cannot_update(@others)
        cannot_delete(@others)
      end
    end
  end
  
  test "name should capitalize on create and save" do
    login_as(@owner)
    post sub_exchanges_path, sub_exchange: {
      name: "lowercase",
      exchange_id: 1
    }
    assert @owner.sub_exchanges.pluck(:name).include?("Lowercase")
    assert !@owner.sub_exchanges.pluck(:name).include?("lowercase")
    
    @owners.name = "downcase"
    @owners.save
    assert @owner.sub_exchanges.pluck(:name).include?("Downcase")
    assert !@owner.sub_exchanges.pluck(:name).include?("downcase")
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
  
  def cannot_index(sub_exchange)
    get exchanges_path
    assert_no_match sub_exchange.name.to_s, 
      response.body
  end
  
  def can_index(sub_exchange)
    get exchanges_path
    assert_match sub_exchange.name.to_s,
      response.body
  end
      
  def cannot_create
    assert_difference 'SubExchange.count', 0 do
      post sub_exchanges_path, sub_exchange: {
        name: "new sub_exchange",
        exchange_id: 1
      }
    end
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'SubExchange.count', 1 do
      post sub_exchanges_path, sub_exchange: {
        name: "new sub_exchange",
        exchange_id: 1
      }
    end
  end
    
  def cannot_update(sub_exchange)
    patch sub_exchange_path(sub_exchange), 
      sub_exchange: {name: "changed sub_exchange"}
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def can_update(sub_exchange)
    assert sub_exchange.name != "changed sub_exchange"
    patch sub_exchange_path(sub_exchange), 
      sub_exchange: {name: "changed sub_exchange"}
    assert sub_exchange.reload.name == "Changed Sub Exchange"
  end
  
  def cannot_delete(sub_exchange)
    assert_difference 'SubExchange.count', 0 do
      delete sub_exchange_path(sub_exchange)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(sub_exchange)
    assert_difference 'SubExchange.count', -1 do
      delete sub_exchange_path(sub_exchange)
    end
  end

end