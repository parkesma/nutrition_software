require 'test_helper'

class EnterMealsTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @eclient_meal = meals(:eclient1_meal)
    @sclient_meal = meals(:sclient1_meal)
    @uclient_meal = meals(:uclient_meal)
    @tclient_meal = meals(:tclient_meal)
    @orphan_meal = meals(:orphan_meal)
    
    @possible_users = [
      @student,
      @ustudent,
      @trainer,
      @employer
    ]
    
    @possible_meals = [
      @eclient_meal,
      @sclient_meal,
      @uclient_meal,
      @tclient_meal
    ]
  end
  
  test "client can index, but not create, update, or delete" do
    login_as(@eclient1)
    focus_on(@eclient1)
    can_index(@eclient_meal)
    cannot_create(@eclient1)
    cannot_update(@eclient_meal)
    cannot_delete(@eclient_meal)
  end

  test "Owner can index, create, update, and delete all" do
    login_as(@owner)
    focus_on(@eclient1)
    can_index(@eclient_meal)
    can_create(@owner)
    can_update(@eclient_meal)
    can_delete(@eclient_meal)
  end
  
  test "Employee can index, create, update, and destroy meals for employer's 
        clients" do
    login_as(@employee)
    focus_on(@eclient1)
    can_index(@eclient_meal)
    can_create(@employee)
    employees_meal = Meal.find_by(name: "new meal by #{@employee.username}")
    assert @employer.clients.include?(employees_meal.user)
    can_update(@eclient_meal)
    can_delete(@eclient_meal)
  end
  
  test "!client && !employee can index, create, update, and destroy meals for their
        own clients, but not another user's" do
    @possible_users.each do |u|
#p "testing #{u.username}"
      login_as(u)
      @possible_meals.each do |m|
        focus_on(m.user)
        if u.clients.include?(m.user)
          can_create(u)
          my_meal = Meal.find_by(name: "new meal by #{u.username}")
          can_index(my_meal)
          can_update(my_meal)
          can_delete(my_meal)
        else
          cannot_create(u)
          cannot_index(m)
          cannot_update(m)
          cannot_delete(m)
        end
#p "#{u.username} passed"
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
  
  def cannot_index(meal)
    get meals_path
    assert_no_match meal.name.to_s, 
      response.body
  end
  
  def can_index(meal)
    get meals_path
    assert_match meal.name.to_s,
      response.body
  end
      
  def cannot_create(user)
    assert_difference 'Meal.count', 0 do
      post meals_path, meal: {name: "new meal by #{user.username}"}
    end
    assert !flash[:danger].blank?
    assert_redirected_to meals_path
  end
  
  def can_create(user)
    assert_difference 'Meal.count', 1 do
      post meals_path, meal: {name: "new meal by #{user.username}"}
    end
  end
    
  def cannot_update(meal)
    patch meal_path(meal), 
      meal: {name: "changed meal"}
    assert !flash[:danger].blank?
    assert_redirected_to meals_path
  end
    
  def can_update(meal)
    assert meal.name != "changed meal"
    patch meal_path(meal), 
      meal: {name: "changed meal"}
    assert meal.reload.name == "changed meal"
  end
  
  def cannot_delete(meal)
    assert_difference 'Meal.count', 0 do
      delete meal_path(meal)
      assert !flash[:danger].blank?
      assert_redirected_to meals_path
    end
  end
  
  def can_delete(meal)
    assert_difference 'Meal.count', -1 do
      delete meal_path(meal)
    end
  end

end