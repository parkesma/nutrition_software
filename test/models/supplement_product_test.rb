require 'test_helper'

class SupplementProductTest < ActiveSupport::TestCase
  def setup
    @supplement = SupplementProduct.new(
      name: "test product",
	    serving_type: "pill",
	    servings_per_bottle: "10",
	    retail_package_type: "bottle",
	    supplement_brand_id: 1
    )
  end
  
  test "name should be present" do
    assert @supplement.valid?
    @supplement.name = nil
    assert !@supplement.valid?
  end
  
  test "serving_type should be present" do
    assert @supplement.valid?
    @supplement.serving_type = nil
    assert !@supplement.valid?
  end
  
  test "servings_per_bottle should be present" do
    assert @supplement.valid?
    @supplement.servings_per_bottle = nil
    assert !@supplement.valid?
  end
  
  test "retail_package_type should be present" do
    assert @supplement.valid?
    @supplement.retail_package_type = nil
    assert !@supplement.valid?
  end
  
  test "supplement_brand_id should be present" do
    assert @supplement.valid?
    @supplement.supplement_brand_id = nil
    assert !@supplement.valid?
  end
  
  test "serving_type should be singularized" do
    @supplement.serving_type = "pills"
    @supplement.save
    assert_equal @supplement.reload.serving_type, "pill"
  end
  
end
