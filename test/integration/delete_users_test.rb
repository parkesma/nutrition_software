require 'test_helper'

class DeleteUsersTest < ActionDispatch::IntegrationTest
  
  def setup
    @client =   users(:client1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @possible_users = [
      @client, 
      @student,
      @ustudent,
      @trainer, 
      @employee,
      @employer,
      @owner
    ]
  end
  
  test "owners can delete users,
        others can only delete their relationship and change expiration" do
    login_as(@owner)
    assert_difference 'User.count', -1 do
      assert_difference 'Relationship.count', -1 do
        delete "/users/#{@client.id}"
      end
    end
    
    login_as(@employer)
    @employee.update_attribute(:expiration_date, Date.tomorrow)

    assert_difference 'User.count', 0 do
      assert_difference 'Relationship.count', -1 do
        delete "/users/#{@employee.id}"
      end
    end

    assert @employee.reload.expiration_date < Time.now

  end
  
  test "clients can't delete anyone" do
    login_as(@client)
    
    assert_difference 'User.count', 0 do
      assert_difference 'Relationship.count', 0 do
        delete "/users/#{@employee.id}"
      end
    end
  end
  
  test "employees can't delete anyone" do
    login_as(@employee)
    
    assert_difference 'User.count', 0 do
      assert_difference 'Relationship.count', 0 do
        delete "/users/#{@client.id}"
      end
    end
  end
  
  test "can't delete someone else's client" do
    login_as(@student)
    
    assert_difference 'User.count', 0 do
      assert_difference 'Relationship.count', 0 do
        delete "/users/#{@client.id}"
      end
    end
  end
  
  test "can't delete someone else's employee" do
    @student.update_attribute(:license, "employer")
    login_as(@student)
    assert_difference 'User.count', 0 do
      assert_difference 'Relationship.count', 0 do
        delete "/users/#{@employee.id}"
      end
    end
  end
  
  test "only an owner can delete these" do
    test_array = [
      @student,
      @ustudent,
      @trainer, 
      @employer,
      @owner
    ]
    @possible_users.each do |u|
      login_as(u)
      test_array.each do |target|
        if u.license == "owner"
          assert_difference 'User.count', -1 do
            delete "/users/#{target.id}"
          end
        else
          assert_difference 'User.count', 0 do
            assert_difference 'Relationship.count', 0 do
              delete "/users/#{target.id}"
            end
          end
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
  
end
