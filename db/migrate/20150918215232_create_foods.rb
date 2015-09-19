class CreateFoods < ActiveRecord::Migration
  def change
    create_table :foods do |t|
      t.belongs_to :subexchange, index:true
      t.string :name
      t.float :carbs_per_serving
      t.float :protein_per_serving
      t.float :fat_per_serving
      t.float :kcals_per_serving
      t.float :servings_per_exchange
      t.float :serving_type
      t.float :supplement_servings_per_bottle

      t.timestamps null: false
    end
  end
end
