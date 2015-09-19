class ChangeServingTypeToString < ActiveRecord::Migration
  def up
    change_column :foods, :serving_type, :string
  end

  def down
    change_column :foods, :serving_type, :float
  end
end