class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.belongs_to :user, index:true
      t.string :name
      t.string :description
      t.float :Kcal_per_kg_per_hr
      t.timestamps null: false
    end
  end
end
