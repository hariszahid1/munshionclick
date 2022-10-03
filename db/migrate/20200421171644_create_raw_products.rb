class CreateRawProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :raw_products do |t|
      t.string :code
      t.string :title
      t.float :stock
      t.integer :acquire_type
      t.float :cost
      t.float :sale
      t.float :minimum
      t.float :optimal
      t.float :maximum

      t.timestamps
    end
  end
end
