require 'test_helper'

class MeasurementsTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient  = users(:eclient1)
    @student  = users(:student)
    @ustudent = users(:ustudent)
    @CFNS     = users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner    = users(:owner)
    @measurement1 = measurements(:eclient1_measurement1)
    @measurement2 = measurements(:eclient1_measurement2)
    
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
	    weight:				1,
	    body_fat:			1,
	    chest:				1,
	    waist:				1,
	    rt_arm:				1,
	    rt_forearm:		1,
	    hips:					1,
	    rt_thigh:	    1,
	    rt_calf:		  1,
    }
  end
  
  test "index should list all measurements" do
    login_as(@employer)
    focus_on(@eclient)
    get measurements_path
    assert_match @measurement1.weight.to_s, response.body
    assert_match @measurement2.weight.to_s, response.body
  end
  
  test "client should see his own measurements, but not add form, edit, 
        or delete options" do
    login_as(@eclient)
    get measurements_path
    assert_match @measurement1.weight.to_s, response.body
    assert_match @measurement2.weight.to_s, response.body
    assert_select "form", count: 0
    assert_select "a", text: "edit", count: 0
    assert_select "a", text: "delete", count: 0
  end
  
  test "client shouldn't be able to add, edit, or delete 
        measurements" do
    login_as(@eclient)
    cannot_create_measurement_for(@eclient)
    cannot_edit(@measurement1, @eclient)
    cannot_delete(@measurement1)
  end
  
  test "owner should be able to create, add, and delete measurements for
        any client" do
    login_as(@owner)
    can_create_measurement_for(@eclient)
    can_edit(@measurement1, @owner)
    can_delete(@measurement1)
  end
  
  test "student, ustudent, trainer, employee, & employer should
        only be able to create, edit, and delete measurements for their 
        own clients" do
    @possible_users.each do |u|
      @possible_targets.each do |t|

        login_as(u)

        if u.clients.include?(t)
          can_create_measurement_for(t)
          can_edit(t.measurements.first, u)
          can_delete(t.measurements.first)
        else
          cannot_create_measurement_for(t)
          cannot_edit(t.measurements.first, u)
          cannot_delete(t.measurements.first)
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
    get measurements_path
    measurements_count = user.measurements.reload.length
    post_via_redirect measurements_path, 
      { measurement: @new_measurement_params }
    assert_equal user.measurements.reload.length, measurements_count + 1
    assert flash[:danger].blank?
    assert !flash[:success].blank?
  end
  
  def cannot_create_measurement_for(user)
    focus_on(user)
    get measurements_path
    measurements_count = user.measurements.reload.length
    post_via_redirect measurements_path, 
      { measurement: @new_measurement_params }
    assert_equal user.measurements.reload.length, measurements_count
    assert !flash[:danger].blank?
    assert flash[:success].blank?
  end
    
  def can_edit(measurement, current_user)
    focus_on(measurement.user)
    get edit_measurement_path(measurement)
    assert measurement.weight != current_user.id * 100
    @new_measurement_params[:weight] = current_user.id * 100
    patch_via_redirect measurement_path(measurement),
      measurement: @new_measurement_params
    assert_equal measurement.reload.weight, current_user.id * 100
    assert flash[:danger].blank?
    assert !flash[:success].blank?
  end
  
  def cannot_edit(measurement, current_user)
    focus_on(measurement.user)
    get edit_measurement_path(measurement)
    assert measurement.weight != current_user.id * 100
    @new_measurement_params[:weight] = current_user.id * 100
    patch_via_redirect measurement_path(measurement),
      measurement: @new_measurement_params
    assert measurement.reload.weight != current_user.id * 100
    assert !flash[:danger].blank?
    assert flash[:success].blank?
  end
  
  def can_delete(measurement)
    user = measurement.user
    measurements_count = user.measurements.reload.length
    delete measurement_path(measurement)
    assert_equal user.measurements.reload.length, measurements_count - 1
    assert flash[:danger].blank?
    assert !flash[:success].blank?
 
  end
  
  def cannot_delete(measurement)
    user = measurement.user
    measurements_count = user.measurements.reload.length
    delete measurement_path(measurement)
    assert_equal user.measurements.reload.length, measurements_count
    assert !flash[:danger].blank?
    assert flash[:success].blank? 
  end
  
end