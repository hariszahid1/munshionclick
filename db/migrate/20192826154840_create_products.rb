class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.references :item_type
      t.string :code
      t.string :title
      t.references :product_category
      t.references :product_sub_category
      t.integer :acquire_type
      t.integer :purchase_type
      t.integer :purchase_unit
      t.integer :purchase_factor
      t.float :cost
      t.float :sale
      t.float :minimum
      t.float :optimal
      t.float :maximum
      t.integer :currency
      t.string :comment

      t.timestamps
    end
  end
end
