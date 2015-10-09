require 'test_helper'

class FoodTest < ActiveSupport::TestCase
  def setup
    @food = Food.new(
      name: "test food",
      carbs_per_serving: "10",
      protein_per_serving: "10",
      fat_per_serving: "10",
      servings_per_exchange: "10",
      serving_type: "oz",
      sub_exchange_id: 1
    )
  end
  
  test "name should be present" do
    assert @food.valid?
    @food.name = nil
    assert !@food.valid?
  end

  test "carbs should be present" do
    assert @food.valid?
    @food.carbs_per_serving = nil
    assert !@food.valid?
  end
  
  test "protein should be present" do
    assert @food.valid?
    @food.protein_per_serving = nil
    assert !@food.valid?
  end
  
  test "fat should be present" do
    assert @food.valid?
    @food.fat_per_serving = nil
    assert !@food.valid?
  end
  
  test "servings per exchange should be present" do
    assert @food.valid?
    @food.servings_per_exchange = nil
    assert !@food.valid?
  end
  
  test "sub_exchange_id should be present" do
    assert @food.valid?
    @food.sub_exchange_id = nil
    assert !@food.valid?
  end
  
  test "serving_type should be singularized" do
    @food.serving_type = "ozs"
    @food.save
    assert_equal @food.reload.serving_type, "oz"
  end
  
end