class CreateLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :links do |t|
      t.references :linkable, polymorphic: true
      t.text :qrcode
      t.text :brcode
      t.text :href
      t.text :title
      t.timestamps
    end
  end
end
