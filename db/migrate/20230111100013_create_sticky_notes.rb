class CreateStickyNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :sticky_notes do |t|
      t.string :title
      t.text :content
      t.integer :x_pos
      t.integer :y_pos
      t.string :color_code

      t.timestamps
    end
  end
end
