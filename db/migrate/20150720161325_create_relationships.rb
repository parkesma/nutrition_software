class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :sub_id
      t.integer :sup_id

      t.timestamps null: false
    end
    add_index :relationships, :sub_id
    add_index :relationships, :sup_id
    add_index :relationships, [:sub_id, :sup_id], unique: true
  end
end
