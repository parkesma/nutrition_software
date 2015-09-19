class CreateMeals < ActiveRecord::Migration
  def change
    create_table :meals do |t|
      t.belongs_to :user, index:true
      t.string :name
      t.time :time
      t.text :notes

      t.timestamps null: false
    end
  end
end
