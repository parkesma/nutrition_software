class AddKcalPerHrToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :kcal_per_hr, :decimal
  end
end
