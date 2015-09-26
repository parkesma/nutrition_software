require 'test_helper'

class EnterFoodAssignmentsTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @eclient_food_assignment = food_assignments(:eclient1_food_assignment)
    @sclient_food_assignment = food_assignments(:sclient1_food_assignment)
    @uclient_food_assignment = food_assignments(:uclient_food_assignment)
    @tclient_food_assignment = food_assignments(:tclient_food_assignment)
    @orphan_food_assignment = food_assignments(:orphan_food_assignment)
    @new_food_sub_exchange = sub_exchanges(:owners)
    
    @possible_users = [
      @student,
      @ustudent,
      @trainer,
      @employer
    ]
    
    @possible_food_assignments = [
      @eclient_food_assignment,
      @sclient_food_assignment,
      @uclient_food_assignment,
      @tclient_food_assignment
    ]
    
    @@count = 0
  end
  
  test "client can index, but not create, update, or delete" do
    login_as(@eclient1)
    focus_on(@eclient1)
    can_index(@eclient_food_assignment)
    cannot_create(@eclient_food_assignment.meal)
    cannot_update(@eclient_food_assignment)
    cannot_delete(@eclient_food_assignment)
  end

  test "Owner can index, create, update, and delete all" do
    login_as(@owner)
    focus_on(@eclient1)
    can_index(@eclient_food_assignment)
    can_create(@eclient_food_assignment.meal)
    can_update(@eclient_food_assignment)
    can_delete(@eclient_food_assignment)
  end
  
  test "Employee can index, create, and update, but not destroy food assignments for 
        employer's clients" do
    login_as(@employee)
    focus_on(@eclient1)
    can_index(@eclient_food_assignment)
    can_create(@eclient_food_assignment.meal)
    employees_food_assignment = FoodAssignment.find_by(number_of_exchanges: 
      100 + @@count)
    assert @employer.clients.include?(employees_food_assignment.meal.user)
    can_update(@eclient_food_assignment)
    cannot_delete(@eclient_food_assignment)
  end
  
  test "!client && !employee can index, create, update, and destroy 
        food_assignments for their own clients, but not another user's" do
    @possible_users.each do |u|
      login_as(u)
      @possible_food_assignments.each do |f|
        focus_on(f.meal.user)
        if u.clients.include?(f.meal.user)
          can_create(f.meal)
          my_food_assignment = FoodAssignment.find_by(number_of_exchanges: 
            100 + @@count)
          can_index(my_food_assignment)
          can_update(my_food_assignment)
          can_delete(my_food_assignment)
        else
          cannot_create(f.meal)
          cannot_index(f)
          cannot_update(f)
          cannot_delete(f)
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
  
  def focus_on(user)
    get user_path(user.id)
  end
  
  def cannot_index(food_assignment)
    get meals_path
    assert_no_match food_assignment.servings_text, response.body
  end
  
  def can_index(food_assignment)
    get meals_path
    assert_match food_assignment.servings_text, response.body
  end
      
  def cannot_create(meal)
    @@count += 1
    assert_difference 'FoodAssignment.count', 0 do
      post food_assignments_path, 
        category: @new_food_sub_exchange.name,
        food_assignment: {
          meal_id: meal.id,
          number_of_exchanges: 100 + @@count
        }
    end
    assert !flash[:danger].blank?
    assert_redirected_to meals_path
  end
  
  def can_create(meal)
    @@count += 1
    assert_difference 'FoodAssignment.count', 1 do
      post food_assignments_path, 
        category: @new_food_sub_exchange.name,
        food_assignment: {
          meal_id: meal.id,
          number_of_exchanges: 100 + @@count
        }
    end
  end
    
  def cannot_update(food_assignment)
    patch food_assignment_path(food_assignment), 
      food_assignment: {number_of_exchanges: 0}
    assert !flash[:danger].blank?
    assert_redirected_to meals_path
  end
    
  def can_update(food_assignment)
    assert food_assignment.number_of_exchanges != 0
    patch food_assignment_path(food_assignment), 
      food_assignment: {number_of_exchanges: 0}
    assert food_assignment.reload.number_of_exchanges == 0
  end
  
  def cannot_delete(food_assignment)
    assert_difference 'FoodAssignment.count', 0 do
      delete food_assignment_path(food_assignment)
      assert !flash[:danger].blank?
      assert_redirected_to meals_path
    end
  end
  
  def can_delete(food_assignment)
    assert_difference 'FoodAssignment.count', -1 do
      delete food_assignment_path(food_assignment)
    end
  end

end