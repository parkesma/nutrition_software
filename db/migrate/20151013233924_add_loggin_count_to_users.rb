class AddLogginCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_count, :int, null: false, default: 0
  end
end
