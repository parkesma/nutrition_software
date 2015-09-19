class AddUserToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :user_id, :integer
    add_column :sub_exchanges, :user_id, :integer
    add_column :foods, :user_id, :integer
  end
end
