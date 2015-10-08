class ChangeScaleOfKcalPerKgPerHr < ActiveRecord::Migration
  def change
    change_column :exercises, :Kcal_per_kg_per_hr, :decimal, precision: 10, scale: 3
  end
end
