class AddTimeOfDayToSupplementAssignment < ActiveRecord::Migration
  def change
    add_column :supplement_assignments, :time_of_day, :time
  end
end
