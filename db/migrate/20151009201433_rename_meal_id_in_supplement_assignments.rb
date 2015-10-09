class RenameMealIdInSupplementAssignments < ActiveRecord::Migration
  def change
    rename_column :supplement_assignments, :meal_id, :user_id
  end
end
