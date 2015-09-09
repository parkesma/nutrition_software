require 'test_helper'

class FatMeasurementsTest < ActionDispatch::IntegrationTest
  def setup
    @fm1 = fat_measurements(:one)
    @fm2 = fat_measurements(:two)
    @fm3 = fat_measurements(:three)
  
    @eclient  = users(:eclient1)
    @student  = users(:student)
    @ustudent = users(:ustudent)
    @CFNS     = users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner    = users(:owner)
    
    @sclient  = users(:sclient1)
    @uclient  = users(:uclient)
    @tclient  = users(:tclient)
    
    @possible_users = [
      @student,
      @ustudent,
      @CFNS,
      @employee,
      @employer
    ]
    
    @possible_targets = [
      @eclient,
      @sclient,
      @uclient,
      @tclient
    ]
    
    @new_measurement_params = {
      weight: 150,
      bf_method: "Sloan"
    }
  end
  

  test "model should find previous_measure" do
    assert_equal @fm3.previous_measure, @fm2
    assert_equal @fm2.previous_measure, @fm1
  end
  
  test "index should list all measurements" do
    login_as(@employer)
    focus_on(@eclient)
    get fat_measurements_path
    assert_match @fm1.created_at.strftime("%b %-d").to_s, 
      response.body
    assert_match @fm2.created_at.strftime("%b %-d").to_s, 
      response.body
    assert_match @fm3.created_at.strftime("%b %-d").to_s, 
      response.body
  end
  
  test "client should see his own measurements, but not add form, 
        edit, or delete options" do
    login_as(@eclient)
    get fat_measurements_path
    assert_match @fm1.created_at.strftime("%b %-d").to_s, 
      response.body
    assert_match @fm2.created_at.strftime("%b %-d").to_s, 
      response.body
    assert_match @fm3.created_at.strftime("%b %-d").to_s, 
      response.body
    assert_select "form", count: 0
    assert_select "a", text: "edit", count: 0
    assert_select "a", text: "delete", count: 0
  end
  
  test "client shouldn't be able to add, edit, or delete 
        measurements" do
    login_as(@eclient)
    cannot_create_measurement_for(@eclient)
    cannot_edit(@fm1, @eclient)
    cannot_delete(@fm1)
  end
  
  test "owner should be able to create, add, and delete 
        measurements for any client" do
    login_as(@owner)
    can_create_measurement_for(@eclient)
    can_edit(@fm1, @owner)
    can_delete(@fm1)
  end
  
  test "student, ustudent, trainer, employee, & employer should
        only be able to create, edit, and delete measurements for their 
        own clients" do
    
    #give each target at least one fat_measurement
    login_as(@owner)
    @possible_targets.each do |t|
      can_create_measurement_for(t)
    end
    
    @possible_users.each do |u|
      @possible_targets.each do |t|

        login_as(u)

        if u.clients.include?(t)
          can_create_measurement_for(t)
          can_edit(t.fat_measurements.first, u)
          can_delete(t.fat_measurements.first)
        else
          cannot_create_measurement_for(t)
          cannot_edit(t.fat_measurements.first, u)
          cannot_delete(t.fat_measurements.first)
        end
      end
    end
  end
  
  def login_as(user)
    post_via_redirect login_path, session: { 
      username: user.username, 
      password: user.password
    }
  end
  
  def focus_on(user)
    get user_path(user.id)
  end
  
  def can_create_measurement_for(user)
    focus_on(user)
    get fat_measurements_path
    fat_measurements_count = user.fat_measurements.reload.length
    post_via_redirect fat_measurements_path, 
      fat_measurement: @new_measurement_params
    assert_equal user.fat_measurements.reload.length, 
      fat_measurements_count + 1
    assert flash[:danger].blank?
    assert !flash[:success].blank?
  end
  
  def cannot_create_measurement_for(user)
    focus_on(user)
    get fat_measurements_path
    fat_measurements_count = user.fat_measurements.reload.length
    post_via_redirect fat_measurements_path, 
      { fat_measurement: @new_measurement_params }
    assert_equal user.fat_measurements.reload.length, 
      fat_measurements_count
    assert !flash[:danger].blank?
    assert flash[:success].blank?
  end
    
  def can_edit(fat_measurement, current_user)
    focus_on(fat_measurement.user)
    get edit_fat_measurement_path(fat_measurement)
    assert fat_measurement.weight != current_user.id * 100 + 
      fat_measurement.user.id
    @new_measurement_params[:weight] = current_user.id * 100 + 
      fat_measurement.user.id
    patch_via_redirect fat_measurement_path(fat_measurement),
      fat_measurement: @new_measurement_params
    assert_equal fat_measurement.reload.weight, 
      current_user.id * 100 + fat_measurement.user.id
    assert flash[:danger].blank?
    assert !flash[:success].blank?
  end
  
  def cannot_edit(fat_measurement, current_user)
    focus_on(fat_measurement.user)
    get edit_fat_measurement_path(fat_measurement)
    assert fat_measurement.weight != current_user.id * 100 + 
      fat_measurement.user.id
    @new_measurement_params[:weight] = current_user.id * 100 + 
      fat_measurement.user.id
    patch_via_redirect fat_measurement_path(fat_measurement),
      fat_measurement: @new_measurement_params
    assert fat_measurement.reload.weight != current_user.id * 100 + 
      fat_measurement.user.id
    assert !flash[:danger].blank?
    assert flash[:success].blank?
  end
  
  def can_delete(fat_measurement)
    user = fat_measurement.user
    fat_measurements_count = user.fat_measurements.reload.length
    delete fat_measurement_path(fat_measurement)
    assert_equal user.fat_measurements.reload.length, 
      fat_measurements_count - 1
    assert flash[:danger].blank?
    assert !flash[:success].blank?
 
  end
  
  def cannot_delete(fat_measurement)
    user = fat_measurement.user
    fat_measurements_count = user.fat_measurements.reload.length
    delete fat_measurement_path(fat_measurement)
    assert_equal user.fat_measurements.reload.length, 
      fat_measurements_count
    assert !flash[:danger].blank?
    assert flash[:success].blank? 
  end

end