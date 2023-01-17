class AddHeightWidthToStickyNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :sticky_notes, :height, :integer, default: 150
    add_column :sticky_notes, :width, :integer, default: 300
  end
end
