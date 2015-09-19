class CreateFoodAssignments < ActiveRecord::Migration
  def change
    create_table :food_assignments do |t|
      t.belongs_to :meal, index:true
      t.belongs_to :food, index:true
      t.float :number_of_exchanges

      t.timestamps null: false
    end
  end
end
