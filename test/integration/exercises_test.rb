require 'test_helper'

class ExercisesTest < ActionDispatch::IntegrationTest
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
  
  test "client should not be able to get new, create, edit, update, 
    or delete exercises" do
    
    login_as(@eclient1)
    
    cannot_get_new
    cannot_create
    cannot_edit(@exercise1)
    cannot_update(@exercise1)
    cannot_delete(@exercise1)
  end
  
  test "!client && !owner should be able to index and show but not edit, 
    update, or delete owner's exercises" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "owner"
        login_as(u)
        can_index(@owners_exercise)
        can_show(@owners_exercise)
        cannot_edit(@owners_exercise)
        cannot_update(@owners_exercise)
        cannot_delete(@owners_exercise)
      end
    end
  end
  
  test "owner should be able to index, show, edit, update, and delete all
    exercises" do
    login_as(@owner)
    Exercise.all.each do |e|
      can_index(e)
      can_show(e)
      can_edit(e)
      can_update(e)
      can_delete(e)
    end
  end
  
  test "employee should be able to index, show, create, edit, and update
    employer's exercises" do
    login_as(@employee)
    can_index(@employers_exercise)
    can_show(@employers_exercise)
    can_edit(@employers_exercise)
    can_update(@employers_exercise)
    cannot_delete(@employers_exercise)
    post exercises_path, exercise: { 
      name: "employees exercise",
      category: "Resistance",
      Kcal_per_kg_per_hr: 10
    }
    employees_exercise = Exercise.find_by(name: "Employees Exercise")
    assert employees_exercise.user = @employer
  end
  
  test "client should be able to index and show, but not edit, update, or delete
    trainer's exercises" do 
  end
  
  test "!client should be able to index, show, create, edit, and 
    delete their own exercises, but not other users'" do
    others_exercise = @exercise2
    @possible_users.each do |u|
      login_as(u)
      
      if u.license != "owner"

          cannot_index(others_exercise)
          cannot_show(others_exercise)
          cannot_edit(others_exercise)
          cannot_update(others_exercise)
          cannot_delete(others_exercise)

      end
      
      if u.license != "client"
        post exercises_path, exercise: {
          name: "#{u.username}s new exercise",
          category: "Resistance",
          Kcal_per_kg_per_hr: 10
        }
        my_exercise = Exercise.find_by(name: "#{u.username.titleize}s New Exercise" )
        can_index(my_exercise)
        can_show(my_exercise)
        can_edit(my_exercise)
        can_update(my_exercise)
        can_delete(my_exercise) if u.license != "employee"

      end
    end
  end
  
  test "name should capitalize on create and save" do
    login_as(@owner)
    post exercises_path, exercise: {
      name: "lowercase",
      category: "Resistance",
      Kcal_per_kg_per_hr: 10
    }
    assert @owner.exercises.pluck(:name).include?("Lowercase")
    assert !@owner.exercises.pluck(:name).include?("lowercase")
    
    @owners_exercise.name = "downcase"
    @owners_exercise.save
    assert @owner.exercises.pluck(:name).include?("Downcase")
    assert !@owner.exercises.pluck(:name).include?("downcase")
  end

  def login_as(user)
    post_via_redirect login_path, session: { 
      username: user.username,
      password: user.password
    }
    @current_user = user
    @license = user.license
  end
  
  def cannot_index(exercise)
    get exercises_path
    assert_no_match exercise.name.to_s, response.body
  end
  
  def can_index(exercise)
    get exercises_path
    assert_match exercise.name.to_s, response.body
  end
  
  def can_show(exercise)
    get exercise_path(exercise)
    assert_match exercise.name.to_s, response.body
  end
  
  def cannot_show(exercise)
    get exercise_path(exercise)
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def cannot_get_new
    get new_exercise_path
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_get_new
    get new_exercise_path
    assert flash[:danger].blank?
    assert_response :success
  end
    
  def cannot_create
    post exercises_path, exercise: {
      name: "name",
      category: "Resistance",
      Kcal_per_kg_per_hr: 10
    }
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'Exercise.count', 1 do
      post exercises_path, exercise: {
        name: "name",
        category: "Resistance",
        Kcal_per_kg_per_hr: 10
      }
    end
  end
    
  def cannot_edit(exercise)
    get edit_exercise_path(exercise)
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end

  def can_edit(exercise)
    get edit_exercise_path(exercise)
    assert_response :success
  end
  
  def cannot_update(exercise)
    patch exercise_path(exercise), exercise: { }
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def can_update(exercise)
    assert exercise.name != 'brand new'
    patch exercise_path(exercise), exercise: {name: 'brand new'}
    assert exercise.name = 'brand new'
  end
  
  def cannot_delete(exercise)
    assert_difference 'Exercise.count', 0 do
      delete exercise_path(exercise)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(exercise)
    assert_difference 'Exercise.count', -1 do
      delete exercise_path(exercise)
    end
  end
    
end