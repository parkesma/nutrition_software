class RemovePrecisionAndScale < ActiveRecord::Migration
  def change
    change_column :fat_measurements, :weight, :decimal
    change_column :fat_measurements, :chest, :decimal
    change_column :fat_measurements, :abdomen, :decimal
    change_column :fat_measurements, :thigh, :decimal
    change_column :fat_measurements, :tricep, :decimal
    change_column :fat_measurements, :subscapular, :decimal
    change_column :fat_measurements, :iliac_crest, :decimal
    change_column :fat_measurements, :calf, :decimal
    change_column :fat_measurements, :bicep, :decimal
    change_column :fat_measurements, :lower_back, :decimal
    change_column :fat_measurements, :neck, :decimal
    change_column :fat_measurements, :measured_bf, :decimal
    change_column :fat_measurements, :midaxillary, :decimal
    change_column :fat_measurements, :hip, :decimal
  end
end
