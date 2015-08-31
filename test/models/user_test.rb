require 'test_helper'

class UserTest < ActiveSupport::TestCase
    
  def setup
    @user = User.new(
      username: "username",
      password: "password",
      license: "client",
      first_name: "John",
      last_name: "Doe"
    )
    @student = users(:student)
    @ustudent = users(:ustudent)
    @trainer = users(:trainer)
    @eclient1 = users(:eclient1)
    @eclient2 = users(:eclient2)
    @employer = users(:employer)
    @employee = users(:employee)
    @sclient1 = users(:sclient1)
    @sclient2 = users(:sclient2)
    @uclient = users(:uclient)
    @tclient = users(:tclient)
  end
  
  test "username should be present" do
    assert @user.valid?
    @user.username = ""
    assert !@user.valid?
  end

  test "username should be unique" do
    @user.username = @student.username
    assert !@user.valid?
  end

  test "password should be present" do
    assert @user.valid?
    @user.password = ""
    assert !@user.valid?
  end 

  test "license should be present" do
    assert @user.valid?
    @user.license = ""
    assert !@user.valid?
  end
  
  test "first name should be present" do
    assert @user.valid?
    @user.first_name = ""
    assert !@user.valid?
  end
  
  test "last name should be present" do
    assert @user.valid?
    @user.last_name = ""
    assert !@user.valid?
  end
  
  test "first and last name should be unique" do
    assert @user.valid?
    @user.first_name = @student.first_name
    assert @user.valid?
    @user.last_name = @student.last_name
    assert !@user.valid?
  end

  test "should find student's clients in subs" do
    assert_equal @student.clients.length, 2
  end

  test "should find unlimited student's clients in subs" do
    @ustudent.clients.each do |c|
      assert_equal c.username, @uclient.username
    end
    assert_equal @ustudent.clients.length, 1
  end
  
  test "should find trainer's clients in subs" do
    @trainer.clients.each do |c|
      assert_equal c.username, @tclient.username
    end
    assert_equal @trainer.clients.length, 1
  end
  
  test "should find employer's clients in subs" do
    assert_equal @employer.clients.length, 2
    assert_equal @employee.clients.length, 2
  end
  
  test "should find employer's employees in subs" do
    assert_equal @employer.employees.length, 1
  end
  
  test "should find employee's employer" do
    assert_equal @employee.employer.username, @employer.username
  end

  test "should find clients' trainers" do
    assert_equal @eclient1.trainer, @employer
    assert_equal @eclient2.trainer, @employer
    assert_equal @sclient1.trainer, @student
    assert_equal @sclient2.trainer, @student
    assert_equal @uclient.trainer, @ustudent
    assert_equal @tclient.trainer, @trainer
  end
  
  test "should calculate basic info correctly" do
    @eclient1.gender = "M"
    @eclient1.resting_heart_rate = 70
    @eclient1.present_weight = 160
    @eclient1.present_body_fat = 20
    @eclient1.height = 68
    @eclient1.date_of_birth = "Tue Jan 1, 1979"
    @eclient1.desired_weight = 150
    @eclient1.desired_body_fat = 10
    @eclient1.measured_metabolic_rate = nil
    @eclient1.activity_index = 1
    assert_equal @eclient1.age.to_i, 36
    assert_equal @eclient1.ibw.to_i, 154
    assert_equal @eclient1.basic_mr.to_i, 1681
    assert_equal @eclient1.sa_needs.to_i, 336
    assert_equal @eclient1.bmr_plus_sa.to_i, 2017
    assert_equal @eclient1.bmr_plus_sa_plus_exercise.to_i, 
      2017 + @eclient1.exercise_calories
    assert_equal @eclient1.tef(@eclient1.present_weight).to_i, 8
    assert_equal @eclient1.tef_factor.to_i, 241
    assert_equal @eclient1.present_energy_expenditure.to_i, 3258

    #adding diet plan will mess these up
      assert_equal @eclient1.daily_caloric_needs.to_i, 2607
      assert_equal @eclient1.daily_deficit.to_i, -651

    assert_equal @eclient1.fluid_min.to_i, 80
    assert_equal @eclient1.fluid_max.to_i, 160
    assert_equal @eclient1.present_lean_mass.to_i, 128
    assert_equal @eclient1.present_fat_mass.to_i, 32
    assert_equal @eclient1.desired_lean_mass.to_i, 135
    assert_equal @eclient1.desired_fat_mass.to_i, 15
    assert_equal @eclient1.estimated_muscle_changes.to_i, 7
    assert_equal @eclient1.estimated_fat_changes.to_i, -17
    assert_equal @eclient1.estimated_total_changes.to_i, 24
    assert_equal @eclient1.target_heart_rate_min.to_i, 138
    assert_equal @eclient1.target_heart_rate_max.to_i, 149
    assert_equal @eclient1.vo2max_endurance_min.to_i, 149
    assert_equal @eclient1.vo2max_endurance_max.to_i, 161
  end

end