class CreateSubExchanges < ActiveRecord::Migration
  def change
    create_table :sub_exchanges do |t|
      t.belongs_to :exchange, index:true
      t.string :name

      t.timestamps null: false
    end
  end
end
