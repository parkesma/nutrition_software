class AddHipToFatMeasurements < ActiveRecord::Migration
  def change
    add_column :fat_measurements, :hip, :float
  end
end
