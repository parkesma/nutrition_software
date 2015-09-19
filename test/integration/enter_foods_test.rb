require 'test_helper'

class EnterFoodsTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @owners = foods(:owners)
    @employers = foods(:employers)
    @others = foods(:others)
    
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
    employees_food = Food.find_by(name: "new food")
    assert_equal employees_food.user, @employer
    can_update(@employers)
    cannot_delete(@employers)
  end
  
  test "!client & !employee can index, create, edit, and delete their own, but not
  another user's" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "employee" && u.license != "owner"
        login_as(u)
        can_create
        my_food = Food.find_by(user_id: u.id)
        can_index(my_food)
        can_update(my_food)
        can_delete(my_food)
        
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
  
  def cannot_index(food)
    get exchanges_path
    assert_no_match food.name.to_s, 
      response.body
  end
  
  def can_index(food)
    get exchanges_path
    assert_match food.name.to_s,
      response.body
  end
      
  def cannot_create
    assert_difference 'Food.count', 0 do
      get new_food_path
      post foods_path, food: {
        sub_exchange_id: 1,
        name: "new food",
        carbs_per_serving: 10,
        protein_per_serving: 10,
        fat_per_serving: 10,
        kcals_per_serving: 10,
        servings_per_exchange: 1,
        serving_type: "slice"
      }
    end
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'Food.count', 1 do
      get new_food_path
      post foods_path, food: {
        sub_exchange_id: 1,
        name: "new food",
        carbs_per_serving: 10,
        protein_per_serving: 10,
        fat_per_serving: 10,
        kcals_per_serving: 10,
        servings_per_exchange: 1,
        serving_type: "slice"
      }
    end
  end
    
  def cannot_update(food)
    get edit_food_path(food)
    patch food_path(food), 
      food: {name: "changed food"}
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def can_update(food)
    get edit_food_path(food)
    assert food.name != "changed food"
    patch food_path(food), 
      food: {name: "changed food"}
    assert food.reload.name == "changed food"
  end
  
  def cannot_delete(food)
    assert_difference 'Food.count', 0 do
      delete food_path(food)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(food)
    assert_difference 'Food.count', -1 do
      delete food_path(food)
    end
  end

end