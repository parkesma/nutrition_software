require 'test_helper'

class EnterSupplementAssignmentsTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @eclient_supplement_assignment = supplement_assignments(:eclient1_supplement_assignment)
    @sclient_supplement_assignment = supplement_assignments(:sclient1_supplement_assignment)
    @uclient_supplement_assignment = supplement_assignments(:uclient_supplement_assignment)
    @tclient_supplement_assignment = supplement_assignments(:tclient_supplement_assignment)
    @orphan_supplement_assignment = supplement_assignments(:orphan_supplement_assignment)
    
    @owners_supplement_product = supplement_products(:owners)
    
    @possible_users = [
      @student,
      @ustudent,
      @trainer,
      @employer
    ]
    
    @possible_supplement_assignments = [
      @eclient_supplement_assignment,
      @sclient_supplement_assignment,
      @uclient_supplement_assignment,
      @tclient_supplement_assignment
    ]
    
    @@count = 0
  end
  
  test "client can index, but not create, update, or delete" do
    login_as(@eclient1)
    focus_on(@eclient1)
    get meals_path
    assert_match @eclient_supplement_assignment.servings_text, response.body
    cannot_create(@eclient_supplement_assignment.meal)
    cannot_update(@eclient_supplement_assignment)
    cannot_delete(@eclient_supplement_assignment)
  end

  test "Owner can index, create, update, and delete all" do
    login_as(@owner)
    focus_on(@eclient1)
    can_index(@eclient_supplement_assignment)
    can_create(@eclient_supplement_assignment.meal)
    can_update(@eclient_supplement_assignment)
    can_delete(@eclient_supplement_assignment)
  end
  
  test "Employee can index, create, update, and destroy supplement assignments for employer's clients" do
    login_as(@employee)
    focus_on(@eclient1)
    can_index(@eclient_supplement_assignment)
    can_create(@eclient_supplement_assignment.meal)
    employees_supplement_assignment = SupplementAssignment.find_by(number_of_servings: 
      100 + @@count)
    assert @employer.clients.include?(employees_supplement_assignment.meal.user)
    can_update(@eclient_supplement_assignment)
    can_delete(@eclient_supplement_assignment)
  end
  
  test "!client && !employee can index, create, update, and destroy 
        supplement_assignments for their own clients, but not another user's" do
    @possible_users.each do |u|
      login_as(u)
      @possible_supplement_assignments.each do |f|
        focus_on(f.meal.user)
        if u.clients.include?(f.meal.user)
          can_create(f.meal)
          my_supplement_assignment = SupplementAssignment.find_by(number_of_servings: 
            100 + @@count)
          can_index(my_supplement_assignment)
          can_update(my_supplement_assignment)
          can_delete(my_supplement_assignment)
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
  
  def cannot_index(supplement_assignment)
    get meals_path
    assert_no_match "value=\"#{'%g' % ('%.2f' % supplement_assignment.number_of_servings)}", response.body
  end
  
  def can_index(supplement_assignment)
    get meals_path
    assert_match "value=\"#{'%g' % ('%.2f' % supplement_assignment.number_of_servings)}", response.body
  end
      
  def cannot_create(meal)
    @@count += 1
    assert_difference 'SupplementAssignment.count', 0 do
      post food_assignments_path, 
        category: @owners_supplement_product.name,
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
    assert_difference 'SupplementAssignment.count', 1 do
      post food_assignments_path, 
        category: @owners_supplement_product.name,
        food_assignment: {
          meal_id: meal.id,
          number_of_exchanges: 100 + @@count
        }
    end
  end
    
  def cannot_update(supplement_assignment)
    patch supplement_assignment_path(supplement_assignment), 
      supplement_assignment: {number_of_servings: 0}
    assert !flash[:danger].blank?
    assert_redirected_to meals_path
  end
    
  def can_update(supplement_assignment)
    assert supplement_assignment.number_of_servings != 0
    patch supplement_assignment_path(supplement_assignment), 
      supplement_assignment: {number_of_servings: 0}
    assert supplement_assignment.reload.number_of_servings == 0
  end
  
  def cannot_delete(supplement_assignment)
    assert_difference 'SupplementAssignment.count', 0 do
      delete supplement_assignment_path(supplement_assignment)
      assert !flash[:danger].blank?
      assert_redirected_to meals_path
    end
  end
  
  def can_delete(supplement_assignment)
    assert_difference 'SupplementAssignment.count', -1 do
      delete supplement_assignment_path(supplement_assignment)
    end
  end

end