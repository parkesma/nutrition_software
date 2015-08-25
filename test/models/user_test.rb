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

end