class ChangeFloatsToDecimals < ActiveRecord::Migration
  def change
    change_column :exercises, :Kcal_per_kg_per_hr,:decimal, precision: 10, scale: 2
    change_column :fat_measurements, :weight, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :chest, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :abdomen, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :thigh, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :tricep, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :subscapular, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :iliac_crest, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :calf, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :bicep, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :lower_back, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :neck, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :measured_bf, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :midaxillary, :decimal, precision: 10, scale: 2
    change_column :fat_measurements, :hip, :decimal, precision: 10, scale: 2
    change_column :food_assignments, :number_of_exchanges, :decimal, precision: 10, scale: 2
    change_column :foods, :carbs_per_serving, :decimal, precision: 10, scale: 2
    change_column :foods, :protein_per_serving, :decimal, precision: 10, scale: 2
    change_column :foods, :fat_per_serving, :decimal, precision: 10, scale: 2
    change_column :foods, :kcals_per_serving, :decimal, precision: 10, scale: 2
    change_column :foods, :servings_per_exchange, :decimal, precision: 10, scale: 2
    remove_column :foods, :supplement_servings_per_bottle
    change_column :measurements, :weight, :decimal, precision: 10, scale: 2
    change_column :measurements, :body_fat, :decimal, precision: 10, scale: 2
    change_column :measurements, :chest, :decimal, precision: 10, scale: 2
    change_column :measurements, :waist, :decimal, precision: 10, scale: 2
    change_column :measurements, :rt_arm, :decimal, precision: 10, scale: 2
    change_column :measurements, :rt_forearm, :decimal, precision: 10, scale: 2
    change_column :measurements, :hips, :decimal, precision: 10, scale: 2
    change_column :measurements, :rt_thigh, :decimal, precision: 10, scale: 2
    change_column :measurements, :rt_calf, :decimal, precision: 10, scale: 2
    change_column :supplement_assignments, :number_of_servings, :decimal, precision: 10, scale: 2
    change_column :users, :resting_heart_rate, :decimal, precision: 10, scale: 2
    change_column :users, :present_weight, :decimal, precision: 10, scale: 2
    change_column :users, :height, :decimal, precision: 10, scale: 2
    change_column :users, :desired_weight, :decimal, precision: 10, scale: 2
    change_column :users, :desired_body_fat, :decimal, precision: 10, scale: 2
    change_column :users, :measured_metabolic_rate, :decimal, precision: 10, scale: 2
    change_column :users, :present_body_fat, :decimal, precision: 10, scale: 2
  end
end
