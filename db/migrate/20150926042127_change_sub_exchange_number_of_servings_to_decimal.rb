class ChangeSubExchangeNumberOfServingsToDecimal < ActiveRecord::Migration
  def change
    change_column :supplement_assignments, :number_of_servings, :decimal
  end
end
