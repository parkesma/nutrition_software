class ChangeTimeOfDayTypeInSupplementAssignments < ActiveRecord::Migration
  def change
    change_column :supplement_assignments, :time_of_day, :string
  end
end
