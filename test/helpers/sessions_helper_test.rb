require 'test_helper'
 
class SessionsHelperTest < ActionView::TestCase
	
	def setup
    @client =   users(:client1)
    @student =  users(:student)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
	end  
	
	test "should login and logout users" do
		assert_not @client.logged_in
		login(@client)
		assert_equal session[:user_id], @client.id
		assert @client.logged_in

		logout(@client)
		assert_nil session[:user_id]
		assert_not @client.logged_in
		
		login(@student)
		assert_equal session[:user_id], @student.id
		assert @student.logged_in

		logout(@student)
		assert_nil session[:user_id]
		assert !@student.logged_in
	end
	
	test "should return current user" do
		login(@trainer)
		assert_equal current_user, @trainer
		logout(@trainer)
		login(@owner)
		assert_equal current_user, @owner
	end

	test "should return current license" do
		login(@trainer)
		assert_equal current_license, "trainer"
		logout(@trainer)
		login(@owner)
		assert_equal current_license, "owner"
	end

  test "should return true if logged in, false if not" do
  	assert !logged_in?
  	login(@client)
  	assert logged_in?
  end
	
end