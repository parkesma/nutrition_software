require 'test_helper'

class EnterVideoTest < ActionDispatch::IntegrationTest

  def setup
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @video1 = videos(:one)
  end
  
  test "video title should be titleized on create" do
    login_as(@owner)
    post videos_path, video: {title: "uncapitalized title", url: "url"}
    assert !Video.find_by(title: "Uncapitalized Title").nil?
  end
  
  test "video title should be titleized on update" do
    login_as(@owner)
    patch video_path(@video1), video: {title: "uncapitalized title"}
    assert_equal @video1.reload.title, "Uncapitalized Title"
  end
  
  test "owner should see edit form" do
    login_as(@owner)
    get videos_path
    assert_select "form input[type=submit]"
  end
  
  test "!owner should not see edit form" do
    login_as(@employer)
    get videos_path
    assert_select "form input[type=submit]", 0
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
  
end
