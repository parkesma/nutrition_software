class RemoveKcalsPerServingFromFoods < ActiveRecord::Migration
  def change
    remove_column :foods, :kcals_per_serving, :decimal
  end
end
