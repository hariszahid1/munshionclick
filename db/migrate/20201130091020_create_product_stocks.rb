class CreateProductStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :product_stocks do |t|
      t.references :product
      t.integer :in_stock
      t.integer :out_stock
      t.integer :stock
      t.integer :cost_price
      t.integer :sale_price

      t.timestamps
    end
  end
end
