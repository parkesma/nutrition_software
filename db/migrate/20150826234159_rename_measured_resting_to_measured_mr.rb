class RenameMeasuredRestingToMeasuredMr < ActiveRecord::Migration
  def change
    rename_column :users, :measured_resting, :measured_metabolic_rate
  end
end
