class RenameFieldInExerciseAssignments < ActiveRecord::Migration
  change_table :exercise_assignments do |t|
    t.rename :hours_per_week, :hrs_per_wk
  end
end
