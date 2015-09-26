class CreateSupplementProducts < ActiveRecord::Migration
  def change
    create_table :supplement_products do |t|
      t.belongs_to :user
      t.belongs_to :supplement_brand
      t.string :name
      t.string :serving_type
      t.integer :servings_per_bottle

      t.timestamps null: false
    end
  end
end
