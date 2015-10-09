require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  
  test "Exercise must have either Kcal_per_kg_per_hr or kcal_per_hr" do
    new_exercise = Exercise.new(
      category: "Cardiovascular",
      name: "new exercise name",
      Kcal_per_kg_per_hr: 10
    )
    assert new_exercise.valid?
    new_exercise.Kcal_per_kg_per_hr = nil
    assert !new_exercise.valid?
    new_exercise.kcal_per_hr = 10
    assert new_exercise.valid?
  end
end
