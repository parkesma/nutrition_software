require 'test_helper'
 
class SessionsHelperTest < ActionView::TestCase
	
	def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
	end  
	
	test "should login and logout users" do
		assert_not @eclient1.logged_in
		login(@eclient1)
		assert_equal session[:user_id], @eclient1.id
		assert @eclient1.logged_in

		logout
		@eclient1.reload
		assert_nil session[:user_id]
		assert_not @eclient1.logged_in
		
		login(@student)
		@student.reload
		assert_equal session[:user_id], @student.id
		assert @student.logged_in

		logout
		@student.reload
		assert_nil session[:user_id]
		assert !@student.logged_in
	end
	
	test "should return current user" do
		login(@trainer)
		assert_equal current_user, @trainer
		logout
		login(@owner)
		assert_equal current_user, @owner
	end

	test "should return current license" do
		login(@trainer)
		assert_equal current_license, "CFNS"
		logout
		login(@owner)
		assert_equal current_license, "owner"
	end

  test "should return true if logged in, false if not" do
  	assert !logged_in?
  	login(@eclient1)
  	assert logged_in?
  end
	
end