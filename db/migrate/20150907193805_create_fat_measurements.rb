class CreateFatMeasurements < ActiveRecord::Migration
  def change
    create_table :fat_measurements do |t|
      t.belongs_to :user, index:true
      t.float :weight
      t.float :chest
      t.float :abdominal
      t.float :thigh
      t.float :triceps
      t.float :subscapular
      t.float :iliac_crest
      t.float :calf
      t.float :bicep
      t.float :lower_back
      t.float :neck
      t.float :other_bf
      
      t.timestamps null: false
    end
  end
end