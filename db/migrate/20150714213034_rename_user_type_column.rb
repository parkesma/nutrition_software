class RenameUserTypeColumn < ActiveRecord::Migration
  change_table :users do |t|
    t.rename :type, :license
  end
end
