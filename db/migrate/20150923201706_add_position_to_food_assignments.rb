class AddPositionToFoodAssignments < ActiveRecord::Migration
  def change
    add_column :food_assignments, :position, :integer
  end
end
