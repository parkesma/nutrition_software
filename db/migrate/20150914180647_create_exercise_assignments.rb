class CreateExerciseAssignments < ActiveRecord::Migration
  def change
    create_table :exercise_assignments do |t|
      t.belongs_to :user, index:true
      t.belongs_to :exercise, index:true
      t.integer :position
      t.integer :hours_per_week

      t.timestamps null: false
    end
  end
end
