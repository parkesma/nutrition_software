class RenameOtherBfInFatMeasurements < ActiveRecord::Migration
  change_table :fat_measurements do |t|
    t.rename :other_bf, :measured_bf
  end
end
