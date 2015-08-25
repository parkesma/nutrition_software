class ChangeCountryFields < ActiveRecord::Migration
  change_table :users do |t|
    t.rename :country, :home_country
    t.string :work_country
  end
end
