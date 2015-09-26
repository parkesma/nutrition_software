require 'test_helper'

class EnterSupplementProductsTest < ActionDispatch::IntegrationTest
  def setup
    @eclient1 = users(:eclient1)
    @student =  users(:student)
    @ustudent = users(:ustudent)
    @trainer =  users(:trainer)
    @employee = users(:employee)
    @employer = users(:employer)
    @owner =    users(:owner)
    
    @owners = supplement_products(:owners)
    @employers = supplement_products(:employers)
    @others = supplement_products(:others)
    
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
    employees = SupplementProduct.find_by(name: "new supplement product")
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
        mine = SupplementProduct.find_by(user_id: u.id)
        can_index(mine)
        can_update(mine)
        can_delete(mine)
        
        cannot_index(@others)
        cannot_update(@others)
        cannot_delete(@others)
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
  
  def focus_on(user)
    get user_path(user.id)
  end
  
  def cannot_index(supplement_product)
    get exchanges_path
    assert_no_match supplement_product.name.to_s, 
      response.body
  end
  
  def can_index(supplement_product)
    get exchanges_path
    assert_match supplement_product.name.to_s,
      response.body
  end
      
  def cannot_create
    assert_difference 'SupplementProduct.count', 0 do
      post supplement_products_path, supplement_product: {
        name: "new supplement product",
        serving_type: "pill",
        servings_per_bottle: 100,
        supplement_brand_id: 1
      }
    end
    assert !flash[:danger].blank?
    assert_redirected_to root_path
  end
  
  def can_create
    assert_difference 'SupplementProduct.count', 1 do
      post supplement_products_path, supplement_product: {
        name: "new supplement product",
        serving_type: "pill",
        servings_per_bottle: 100,
        supplement_brand_id: 1
      }
    end
  end
    
  def cannot_update(supplement_product)
    @i = @i ? @i + 1 : 1
    patch supplement_product_path(supplement_product), 
      supplement_product: {name: "changed supplement product#{@i}"}
    assert !flash[:danger].blank?
    assert_redirected_to root_path
    assert supplement_product.reload.name != "changed supplement product#{@i}"
  end
    
  def can_update(supplement_product)
    @i = @i ? @i + 1 : 1
    assert supplement_product.name != "changed supplement product#{@i}"
    patch supplement_product_path(supplement_product), 
      supplement_product: {name: "changed supplement product#{@i}"}
    assert supplement_product.reload.name == "changed supplement product#{@i}"
  end
  
  def cannot_delete(supplement_product)
    assert_difference 'SupplementProduct.count', 0 do
      delete supplement_product_path(supplement_product)
      assert !flash[:danger].blank?
      assert_redirected_to root_path
    end
  end
  
  def can_delete(supplement_product)
    assert_difference 'SupplementProduct.count', -1 do
      delete supplement_product_path(supplement_product)
    end
  end

end