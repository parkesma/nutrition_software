class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :type
      t.integer :trainer_id
      t.date :expiration_date
      t.boolean :graduated?
      t.string :website1
      t.string :website2
      t.string :first_name
      t.string :last_name
      t.date :starting_date
      t.date :date_of_birth
      t.string :gender
      t.string :body_fat_method
      t.string :meal_plan
      t.string :home_address_1
      t.string :home_address_2
      t.string :city
      t.string :state
      t.integer :zip
      t.string :country
      t.string :work_address_1
      t.string :work_address_2
      t.string :city
      t.string :state
      t.integer :zip
      t.string :country
      t.string :email
      t.string :home_phone
      t.string :mobile_phone
      t.string :work_phone
      t.string :other_phone
      t.string :notes
      t.float :resting_heart_rate
      t.float :present_weight
      t.float :height
      t.float :desired_weight
      t.float :desired_body_fat
      t.float :measured_resting
      t.integer :activity_index
      t.boolean :display_website1
      t.boolean :display_website2
      t.boolean :display_address
      t.boolean :display_email
      t.boolean :display_home_phone
      t.boolean :display_mobile_phone
      t.boolean :display_work_phone
      t.boolean :display_other_phone
      t.boolean :firing

      t.timestamps null: false
    end
  end
end
