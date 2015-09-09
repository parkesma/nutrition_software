class AddBfMethodToFatMeasurements < ActiveRecord::Migration
  def change
    add_column :fat_measurements, :bf_method, :string
  end
end
