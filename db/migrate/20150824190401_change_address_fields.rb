class ChangeAddressFields < ActiveRecord::Migration
  change_table :users do |t|
    t.rename :city, :home_city
    t.rename :state, :home_state
    t.rename :zip, :home_zip
    t.string :work_city, :work_state
    t.integer :work_zip
  end
end
