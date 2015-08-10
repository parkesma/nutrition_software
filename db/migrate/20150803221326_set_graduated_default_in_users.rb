class SetGraduatedDefaultInUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :graduated, false
  end
end
