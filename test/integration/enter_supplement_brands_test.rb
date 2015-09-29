require 'test_helper'

class EnterSupplementBrandsTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @owners = supplement_brands(:owners)
    @employers = supplement_brands(:employers)
    @others = supplement_brands(:others)
    
    @possible_users = [
      @eclient1,
      @student,
      @ustudent,
      @trainer,
      @employee,
      @employer,
      @owner
    ]  
  end
  
  test "client can't index, create, update, or delete any" do
    login_as(@eclient1)
    cannot_index(@owners)
    cannot_create
    cannot_update(@owners)
    cannot_delete(@owners)
  end

  test "!client && !owner can index but not update or delete owner's" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "owner"
        login_as(u)
        can_index(@owners)
        cannot_update(@owners)
        cannot_delete(@owners)
      end
    end
  end
  
  test "Owner can index, create, update, and delete all" do
    login_as(@owner)
    can_index(@employers)
    can_create
    can_update(@employers)
    can_delete(@employers)
  end
  
  test "Employee can index, create, and edit, but not delete employer's" do
    login_as(@employee)
    can_index(@employers)
    can_create
    employees = SupplementBrand.find_by(name: "New Supplement Brand")
    assert_equal employees.user, @employer
    can_update(@employers)
    cannot_delete(@employers)
  end
  
  test "!client & !employee can index, create, edit, and delete their own, but not
  another user's" do
    @possible_users.each do |u|
      if u.license != "client" && u.license != "employee" && u.license != "owner"
        login_as(u)
        can_create
        mine = SupplementBrand.find_by(user_id: u.id)
        can_index(mine)
        can_update(mine)
        can_delete(mine)
        
        cannot_index(@others)
        cannot_update(@others)
        cannot_delete(@others)
      end
    end
  end
  
  test "name should capitalize on create and save" do
    login_as(@owner)
    post supplement_brands_path, supplement_brand: {
      name: "lowercase"
    }
    assert @owner.supplement_brands.pluck(:name).include?("Lowercase")
    assert !@owner.supplement_brands.pluck(:name).include?("lowercase")
    
    @owners.name = "downcase"
    @owners.save
    assert @owner.supplement_brands.pluck(:name).include?("Downcase")
    assert !@owner.supplement_brands.pluck(:name).include?("downcase")
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
  
  def cannot_index(supplement_brand)
    get exchanges_path
    assert_no_match supplement_brand.name.to_s, 
      response.body
  end
  
  def can_index(supplement_brand)
    get exchanges_path
    assert_match supplement_brand.name.to_s,
      response.body
  end
      
  def cannot_create
    assert_difference 'SupplementBrand.count', 0 do
      post supplement_brands_path, supplement_brand: {name: "new supplement brand"}
    end
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'SupplementBrand.count', 1 do
      post supplement_brands_path, supplement_brand: {name: "new supplement brand"}
    end
  end
    
  def cannot_update(supplement_brand)
    patch supplement_brand_path(supplement_brand), 
      supplement_brand: {name: "changed supplement brand"}
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
    
  def can_update(supplement_brand)
    assert supplement_brand.name != "changed supplement_brand"
    patch supplement_brand_path(supplement_brand), 
      supplement_brand: {name: "changed supplement brand"}
    assert supplement_brand.reload.name == "Changed Supplement Brand"
  end
  
  def cannot_delete(supplement_brand)
    assert_difference 'SupplementBrand.count', 0 do
      delete supplement_brand_path(supplement_brand)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(supplement_brand)
    assert_difference 'SupplementBrand.count', -1 do
      delete supplement_brand_path(supplement_brand)
    end
  end

end