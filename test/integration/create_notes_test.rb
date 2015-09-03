require 'test_helper'

class CreateNotesTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    @note1 =    notes(:note1)
    @note2 =    notes(:note2)
  end
  
  test "index should list all notes" do
    login_as(@employer)
    focus_on(@eclient1)
    get notes_path
    assert_match @note1.text, response.body
    assert_match @note2.text, response.body
  end

  test "new note should show author" do
    login_as(@employer)
    focus_on(@eclient1)
    get notes_path
    assert_equal @eclient1.notes.length, 2
    assert_match @employer.name, response.body, count: 1
    post_via_redirect notes_path, note: {
      user_id: @eclient1.id,
      text: "new note"
    }
    assert_template 'notes/index'
    assert flash[:danger].blank?
    assert_equal @eclient1.notes.reload.length, 3 
    @eclient1.notes.each do |n|
      assert_match n.author.name, response.body
      assert_match n.text, response.body
    end
    assert_match @employer.name, response.body, count: 2
  end
  
  test "client shouldn't be able to add notes" do
  end
  
  test "owner should be able to add notes to any client" do
  end
  
  test "student, ustudent, trainer, employee, & employer should
        only be able to add notes to their own clients" do
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