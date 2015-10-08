class ChangeHrsPerWeekToDecimal < ActiveRecord::Migration
  def change
    change_column :exercise_assignments, :hrs_per_wk, :decimal
  end
end
