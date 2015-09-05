class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.belongs_to :user, index:true
      t.float :weight
      t.float :body_fat
      t.float :chest
      t.float :waist
      t.float :rt_arm
      t.float :rt_forearm
      t.float :hips
      t.float :rt_thigh
      t.float :rt_calf

      t.timestamps null: false
    end
  end
end
