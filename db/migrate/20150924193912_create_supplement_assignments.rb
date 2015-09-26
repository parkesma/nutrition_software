class CreateSupplementAssignments < ActiveRecord::Migration
  def change
    create_table :supplement_assignments do |t|
      t.belongs_to :supplement_product
      t.belongs_to :meal
      t.integer :number_of_servings

      t.timestamps null: false
    end
  end
end
