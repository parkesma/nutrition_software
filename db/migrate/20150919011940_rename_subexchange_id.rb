class RenameSubexchangeId < ActiveRecord::Migration
  def change
    rename_column :foods, :subexchange_id, :sub_exchange_id
  end
end
