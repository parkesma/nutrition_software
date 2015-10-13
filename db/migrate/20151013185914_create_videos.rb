class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :url
      t.integer :position
      t.timestamps null: false
    end
  end
end
