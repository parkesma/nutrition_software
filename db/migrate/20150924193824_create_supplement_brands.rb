class CreateSupplementBrands < ActiveRecord::Migration
  def change
    create_table :supplement_brands do |t|
      t.belongs_to :user
      t.string :name

      t.timestamps null: false
    end
  end
end
