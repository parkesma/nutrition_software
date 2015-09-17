require 'test_helper'

class ExerciseAssignmentsTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @exercise1 = exercises(:one)
    @exercise2 = exercises(:two)
    @owners_exercise = exercises(:owners)
    @employers_exercise = exercises(:employers)
    @exercise_assignment1 = exercise_assignments(:one)
    @broken_assignment = exercise_assignments(:broken)
    
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

  test "client should be able to index, but not create, update, or
    delete exercises" do
    login_as(@eclient1)
    can_index(@exercise_assignment1)
    cannot_create
    cannot_update(@exercise_assignment1)
    cannot_delete(@exercise_assignment1)
  end
  
  test "employer should be able to index, create, update, 
    and delete the exercise plans for employer's client" do
    login_as(@employer)
    focus_on(@eclient1)
    can_index(@exercise_assignment1)
    can_create
    can_update(@exercise_assignment1)
    can_delete(@exercise_assignment1)
  end
  
  test "employee should be able to index, create, update, 
    and delete the exercise plans for employer's client" do
    login_as(@employee)
    focus_on(@eclient1)
    can_index(@exercise_assignment1)
    can_create
    can_update(@exercise_assignment1)
    can_delete(@exercise_assignment1)
  end

  test "owner should be able to index, update, and delete all
    exercise plans" do
    login_as(@owner)
    focus_on(@eclient1)
    can_index(@exercise_assignment1)
    can_update(@exercise_assignment1)
    can_delete(@exercise_assignment1)
  end
  
  test "assignment with no associated exercise should rescue" do
    login_as(@owner)
    focus_on(@eclient1)
    get exercise_assignments_path
    assert_response :success
    get basic_info_path
    assert_response :success
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
  
  def cannot_index(exercise_assignment)
    get exercise_assignments_path
    assert_no_match exercise_assignment.exercise.name.to_s, 
      response.body
  end
  
  def can_index(exercise_assignment)
    get exercise_assignments_path
    assert_match exercise_assignment.exercise.name.to_s, 
      response.body
  end
      
  def cannot_create
    post exercise_assignments_path, exercise_assignment: {
      user_id: @eclient1.id,
      exercise_id: @exercise1.id,
      hrs_per_wk: 10
    }
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'ExerciseAssignment.count', 1 do
      post exercise_assignments_path, exercise_assignment: {
        user_id: @eclient1.id,
        exercise_id: @employers_exercise.id,
        hrs_per_wk: 10
      }
    end
  end
    
  def cannot_update(exercise_assignment)
    patch exercise_assignment_path(exercise_assignment), 
      exercise_assignment: {hrs_per_wk: 3}
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def can_update(exercise_assignment)
    assert exercise_assignment.hrs_per_wk != '3'
    patch exercise_assignment_path(exercise_assignment), 
      exercise_assignment: {hrs_per_wk: 3}
    assert exercise_assignment.hrs_per_wk = '3'
  end
  
  def cannot_delete(exercise_assignment)
    assert_difference 'ExerciseAssignment.count', 0 do
      delete exercise_assignment_path(exercise_assignment)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(exercise_assignment)
    assert_difference 'ExerciseAssignment.count', -1 do
      delete exercise_assignment_path(exercise_assignment)
    end
  end
  
end