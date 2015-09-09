class AddMidaxillaryToFatMeasurements < ActiveRecord::Migration
  change_table :fat_measurements do |t|
    t.float :midaxillary
    t.rename :triceps, :tricep
    t.rename :abdominal, :abdomen
  end
end
