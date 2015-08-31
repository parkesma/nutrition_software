class FixBasicUserFields < ActiveRecord::Migration
  def change
    remove_column :users, :display_website1, :boolean
    remove_column :users, :display_website2, :boolean
    remove_column :users, :display_address, :boolean
    remove_column :users, :display_email, :boolean
    remove_column :users, :display_home_phone, :boolean
    remove_column :users, :display_mobile_phone, :boolean
    remove_column :users, :display_work_phone, :boolean
    remove_column :users, :display_other_phone, :boolean
    remove_column :users, :firing, :boolean
    remove_column :users, :notes, :string
    remove_column :users, :body_fat_method, :string
    remove_column :users, :meal_plan, :string
    add_column :users, :present_body_fat, :float
  end
end
