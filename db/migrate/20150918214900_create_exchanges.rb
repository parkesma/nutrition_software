class CreateExchanges < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
