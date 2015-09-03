require 'test_helper'

class NotesTest < ActionDispatch::IntegrationTest
  
  def setup
    @eclient  = users(:eclient1)
    @student  = users(:student)
    @ustudent = users(:ustudent)
    @CFNS     = users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner    = users(:owner)
    @note1    = notes(:eclient1_note1)
    @note2    = notes(:eclient1_note2)
    
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
  end
  
  test "index should list all notes" do
    login_as(@employer)
    focus_on(@eclient)
    get notes_path
    assert_match @note1.text, response.body
    assert_match @note2.text, response.body
  end

  test "new note should show author" do
    login_as(@employer)
    focus_on(@eclient)
    get notes_path
    assert_equal @eclient.notes.length, 2
    assert_match @employer.name, response.body, count: 1
    post_via_redirect notes_path, note: {
      user_id: @eclient.id,
      text: "new note"
    }
    assert_template 'notes/index'
    assert flash[:danger].blank?
    assert_equal @eclient.notes.reload.length, 3 
    @eclient.notes.each do |n|
      assert_match n.author.name, response.body
      assert_match n.text, response.body
    end
    assert_match @employer.name, response.body, count: 2
  end
  
  test "client should see his own notes, but not add form, edit, 
        or delete options" do
    login_as(@eclient)
    get notes_path
    assert_match @note1.text, response.body
    assert_match @note2.text, response.body
    assert_select "form", count: 0
    assert_select "a", text: "edit", count: 0
    assert_select "a", text: "delete", count: 0
  end
  
  test "client shouldn't be able to add, edit, or delete notes" do
    login_as(@eclient)
    cannot_create_note_for(@eclient)
    cannot_edit(@note1, @eclient)
    cannot_delete(@note1)
  end
  
  test "owner should be able to create, add, and delete notes for
        any client" do
    login_as(@owner)
    can_create_note_for(@eclient)
    new_note = Note.find_by(text: "new note")
    can_edit(new_note, @owner)
    can_delete(new_note)
  end
  
  test "student, ustudent, trainer, employee, & employer should
        only be able to create, edit, and delete notes for their 
        own clients" do
    @possible_users.each do |u|
      @possible_targets.each do |t|

        login_as(u)

        if u.clients.include?(t)
          can_create_note_for(t)
          can_edit(t.notes.first, u)
          can_delete(t.notes.first)
        else
          cannot_create_note_for(t)
          cannot_edit(t.notes.first, u)
          cannot_delete(t.notes.first)
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
  
  def logout
    delete logout_path
  end
  
  def focus_on(user)
    get user_path(user.id)
  end
  
  def can_create_note_for(user)
    focus_on(user)
    get notes_path
    notes_count = user.notes.reload.length
    post_via_redirect notes_path, note: {
      text: "new note"
    }
    assert_equal user.notes.reload.length, notes_count + 1
    assert flash[:danger].blank?
    assert !flash[:success].blank?
  end
  
  def cannot_create_note_for(user)
    focus_on(user)
    get notes_path
    notes_count = user.notes.reload.length
    post_via_redirect notes_path, note: {
      text: "new note"
    }
    assert_equal user.notes.reload.length, notes_count
    assert !flash[:danger].blank?
    assert flash[:success].blank?
  end
    
  def can_edit(note, author)
    focus_on(note.user)
    get edit_note_path(note)
    patch_via_redirect note_path(note), note: {
      text: "#{author.username} editted note"
    }
    assert_match "#{author.username} editted note", response.body
    assert flash[:danger].blank?
    assert !flash[:success].blank?
  end
  
  def cannot_edit(note, author)
    focus_on(note.user)
    get edit_note_path(note)
    patch_via_redirect note_path(note), note: {
      text: "#{author.username} editted note"
    }
    assert_no_match "#{author.username} editted note", response.body
    assert !flash[:danger].blank?
    assert flash[:success].blank?
  end
  
  def can_delete(note)
    user = note.user
    notes_count = user.notes.reload.length
    delete note_path(note)
    assert_equal user.notes.reload.length, notes_count - 1
    assert flash[:danger].blank?
    assert !flash[:success].blank?
 
  end
  
  def cannot_delete(note)
    user = note.user
    notes_count = user.notes.reload.length
    delete note_path(note)
    assert_equal user.notes.reload.length, notes_count
    assert !flash[:danger].blank?
    assert flash[:success].blank? 
  end
  
end