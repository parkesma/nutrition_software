class AddCatagoryToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :category, :string
  end
end
