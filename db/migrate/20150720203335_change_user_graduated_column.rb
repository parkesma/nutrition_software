class ChangeUserGraduatedColumn < ActiveRecord::Migration
  change_table :users do |t|
    t.rename :graduated?, :graduated
  end
end
