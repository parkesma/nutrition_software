class AddClothingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :clothing, :string
  end
end
